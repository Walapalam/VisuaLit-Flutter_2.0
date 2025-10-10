// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.resetMonthlyCredits = functions.pubsub.schedule("0 0 1 * *")
    .onRun(async (context) => {
      const db = admin.firestore();
      const usersSnapshot = await db.collection("users").get();

      const updates = [];
      usersSnapshot.forEach((doc) => {
        const user = doc.data();
        const newCredits = user.isPremium ? 100 : 20;
        updates.push(
            db.collection("users").doc(doc.id).update({credits: newCredits}),
        );
      });

      await Promise.all(updates);
      console.log("Monthly credits have been reset.");
      return null;
    });
