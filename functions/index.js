const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.observeLikes = functions.database.ref('/user-likes/{uid}/{postId}').onCreate((snapshot, context) => {

  var uid = context.params.uid;
  var postId = context.params.postId;

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var userThatLikedPost = snapshot.val();

    return admin.database().ref('/posts/' + postId).once('value', snapshot => {
      var post = snapshot.val();

        return admin.database().ref('/users/' + post.ownerUid).once('value', snapshot => {
          var postOwner = snapshot.val();

          var payload = {
            notification: {
              body: userThatLikedPost.name + ' liked your post'
            }
          };

          admin.messaging().sendToDevice(postOwner.fcmToken, payload)
            .then(function(response) {
              // Response is a message ID string.
              console.log('Successfully sent message:', response);
            })
            .catch(function(error) {
              console.log('Error sending message:', error);
            });

      })
    })
  })
})

exports.observeFollow = functions.database.ref('/user-following/{uid}/{followedUid}').onCreate((snapshot, context) => {

  var uid = context.params.uid;
  var followedUid = context.params.followedUid;

  return admin.database().ref('/users/' + followedUid).once('value', snapshot => {
    var userThatWasFollowed = snapshot.val();

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
      var userThatFollowed = snapshot.val();

      var payload = {
        notification: {
          title: 'You have a new follower!',
          body: userThatFollowed.name + ' started following you'
        }
      };

      admin.messaging().sendToDevice(userThatWasFollowed.fcmToken, payload)
        .then(function(response) {
          // Response is a message ID string.
          console.log('Successfully sent message:', response);
        })
        .catch(function(error) {
          console.log('Error sending message:', error);
        });
    })
  })
})

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.sendPushNotification = functions.https.onRequest((req, res) => {

  res.send("Attempting to send push notification")
  console.log("LOGGER --- Trying to send push message..");

  var uid = 'DEWOWNYJlXgSOmCArXvZvhCRq643'

  var fcmToken = 'cCCx8I_Wd0mmsUjb2zE8Bt:APA91bHxi2VSK-4Fy0bBjGzPMBWFdTlQKcBqy-u9xmt4jmdnknEJzw8KPE2dDU69821cw8cMcDsa53sRrZgGhw_NNxVSZqpD0yh7u6VpOLdiiLrh5-1xB6l3rDuUiNuVFwIbJiXoOsjL'

  return admin.database().ref('/users/' + uid).once('value', snapshot => {

    var user = snapshot.val();

    console.log("Name is " + user.name);

    var payload = {
      notification: {
        title: 'Push Notification Title',
        body: 'Test Notification Message'
      }
    }

    admin.messaging().sendToDevice(fcmToken, payload)
      .then(function(response) {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
      })
      .catch(function(error) {
        console.log('Error sending message:', error);
      });

  })

})
