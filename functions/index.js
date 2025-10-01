const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { token, title, body, bodyLocKey, bodyLocArgs, extraData } = req.body;

    if (!token || !title || !body) {
      return res.status(400).send({ error: "Missing fields" });
    }

    const message = {
      token,
      android: {
        notification: {
          title: title,
          body: body,
          bodyLocKey: bodyLocKey || null,
          bodyLocArgs: bodyLocArgs || [],
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              "loc-key": bodyLocKey || null,
              "loc-args": bodyLocArgs || [],
            },
          },
        },
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        id: "1",
        status: "done",
        myMap: JSON.stringify(extraData || {}), // <-- Pass map as JSON string
      },
    };

    await admin.messaging().send(message);
    return res.status(200).send({ success: true });
  } catch (error) {
    console.error("Error sending notification:", error);
    return res.status(500).send({ error: error.message });
  }
});

