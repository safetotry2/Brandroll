const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.observeMessages = functions.database.ref('/messages/{messageId}').onCreate((snapshot, context) => {
  var messageId = context.params.messageId;

  return admin.database().ref('/messages/' + messageId).once('value', snapshot => {
    var message = snapshot.val();
    var messageSenderId = message.fromId;
    var messageReceiverId = message.toId;

    return admin.database().ref('/users/' + messageSenderId).once('value', snapshot => {
      var messageSender = snapshot.val();

      return admin.database().ref('/users/' + messageReceiverId).once('value', snapshot => {
        var messageReceiver = snapshot.val();
        var messageReceiverKey = snapshot.key

        return this.userPrefIsOn(messageReceiverKey, 'direct-messages').then(function (isOn) {
          if (isOn) {
            var payload = {
              notification: {
                body: messageSender.name + ' sent you a message.'
              }
            };

            admin.messaging().sendToDevice(messageReceiver.fcmToken, payload)
              .then(function (response) {
                // Response is a message ID string.
                console.log('Successfully sent message:', response);
              })
              .catch(function (error) {
                console.log('Error sending message:', error);
              });
          }
        })
      })
    })
  })
})

exports.observeComments = functions.database.ref('/comments/{postId}/{commentId}').onCreate((snapshot, context) => {
  var postId = context.params.postId;
  var commentId = context.params.commentId;

  return admin.database().ref('/comments/' + postId + '/' + commentId).once('value', snapshot => {
    var comment = snapshot.val();
    var commentUid = comment.uid;

    return admin.database().ref('/users/' + commentUid).once('value', snapshot => {
      var commentingUser = snapshot.val();

      return admin.database().ref('/posts/' + postId).once('value', snapshot => {
        var post = snapshot.val();
        var postOwnerUid = post.ownerUid;

        return admin.database().ref('/users/' + postOwnerUid).once('value', snapshot => {
          var postOwner = snapshot.val();

          return this.userPrefIsOn(postOwnerUid, 'comments').then(function (isOn) {
            if (isOn) {
              var payload = {
                notification: {
                  body: commentingUser.name + ' commented on your post.'
                }
              };

              admin.messaging().sendToDevice(postOwner.fcmToken, payload)
                .then(function (response) {
                  // Response is a message ID string.
                  console.log('Successfully sent message:', response);
                })
                .catch(function (error) {
                  console.log('Error sending message:', error);
                });
            }
          })
        })
      })
    })
  })
})

exports.observeLikes = functions.database.ref('/user-likes/{uid}/{postId}').onCreate((snapshot, context) => {

  var uid = context.params.uid;
  var postId = context.params.postId;

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var userThatLikedPost = snapshot.val();

    return admin.database().ref('/posts/' + postId).once('value', snapshot => {
      var post = snapshot.val();

      return admin.database().ref('/user-push-notif-pref/' + uid).once('value', snapshot => {
        var userPref = snapshot.val()
        var newFollowerNotifIsOn = userPref["likes"] == true

        return admin.database().ref('/users/' + post.ownerUid).once('value', snapshot => {
          var postOwner = snapshot.val();
          const postOwnerKey = snapshot.key

          return this.userPrefIsOn(postOwnerKey, 'likes').then(function (isOn) {
            if (isOn) {
              var payload = {
                notification: {
                  body: userThatLikedPost.name + ' liked your post.'
                }
              };

              admin.messaging().sendToDevice(postOwner.fcmToken, payload)
                .then(function (response) {
                  // Response is a message ID string.
                  console.log('Successfully sent message:', response);
                })
                .catch(function (error) {
                  console.log('Error sending message:', error);
                });
            }
          })
        })
      })
    })
  })
})

exports.observeFollow = functions.database.ref('/user-following/{uid}/{followedUid}').onCreate((snapshot, context) => {

  var uid = context.params.uid;
  var followedUid = context.params.followedUid;

  return admin.database().ref('/users/' + followedUid).once('value', snapshot => {
    var userThatWasFollowed = snapshot.val();
    var userThatWasFollowedKey = snapshot.key

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
      var userThatFollowed = snapshot.val();

      return this.userPrefIsOn(userThatWasFollowedKey, 'new-followers').then(function (isOn) {
        if (isOn) {
          var payload = {
            notification: {
              //title: 'You have a new follower!',
              body: userThatFollowed.name + ' started following you.'
            }
          };

          admin.messaging().sendToDevice(userThatWasFollowed.fcmToken, payload)
            .then(function (response) {
              // Response is a message ID string.
              console.log('Successfully sent message:', response);
            })
            .catch(function (error) {
              console.log('Error sending message:', error);
            });
        }
      })
    })
  })
})

exports.userPrefIsOn = async (receiverId, userPrefType) => {
  try {
    const snapshot = await admin.database().ref('/user-push-notif-pref/' + receiverId).once('value')
    const userPref = snapshot.val()
    const isOn = userPref[userPrefType] == true
    return isOn
  } catch (err) {
    console.log("Error fetching user pref: " + err.message)
    throw new Error("An error has occured while fetching user pref.")
  }
}