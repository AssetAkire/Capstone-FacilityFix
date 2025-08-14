const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.createUserWithClaims = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {email, password, firstName, lastName, userRole, buildingId, unitId} =
    data;

  if (!email || !password || !firstName || !lastName || !userRole) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required user data.",
    );
  }

  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${firstName} ${lastName}`,
    });

    const uid = userRecord.uid;

    await admin.auth().setCustomUserClaims(uid, {user_role: userRole});

    await db
        .collection("users")
        .doc(uid)
        .set({
          id: uid,
          username: email.split("@")[0],
          email: email,
          password_hash: "N/A",
          first_name: firstName,
          last_name: lastName,
          phone_number: null,
          user_role: userRole,
          department: null,
          status: "active",
          building_id: buildingId || null,
          unit_id: unitId || null,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });

    console.log(`User ${email} created with UID: ${uid} and role: ${userRole}`);
    return {uid: uid, message: "User created successfully!"};
  } catch (error) {
    console.error("Error creating user:", error);
    if (error.code === "auth/email-already-in-use") {
      throw new functions.https.HttpsError(
          "already-exists",
          "The email address is already in use by another account.",
      );
    }
    if (error.code && error.message) {
      throw new functions.https.HttpsError(
          "internal",
          `Firebase Admin SDK error: ${error.code} - ${error.message}`,
          error.details,
      );
    }
    throw new functions.https.HttpsError(
        "internal",
        "Failed to create user.",
        error.message,
    );
  }
});

exports.setUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token.user_role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only administrators can set user roles.",
    );
  }

  const {targetUid, newRole} = data;

  if (!targetUid || !newRole) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing target UID or new role.",
    );
  }

  const validRoles = ["admin", "staff", "tenant"];
  if (!validRoles.includes(newRole)) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid role specified.",
    );
  }

  try {
    await admin.auth().setCustomUserClaims(targetUid, {user_role: newRole});

    await db.collection("users").doc(targetUid).update({
      user_role: newRole,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`User ${targetUid} role updated to: ${newRole}`);
    return {success: true, message: `User role updated to ${newRole}`};
  } catch (error) {
    console.error("Error setting user role:", error);
    if (error.code && error.message) {
      throw new functions.https.HttpsError(
          "internal",
          `Firebase Admin SDK error: ${error.code} - ${error.message}`,
          error.details,
      );
    }
    throw new functions.https.HttpsError(
        "internal",
        "Failed to set user role.",
        error.message);
  }
});

exports.deleteUserAndData = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token.user_role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only administrators can delete user accounts.",
    );
  }

  const {targetUid} = data;

  if (!targetUid) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing target UID.",
    );
  }

  if (context.auth.uid === targetUid) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "An administrator cannot delete their own account using this function.",
    );
  }

  try {
    const batch = db.batch();

    await admin.auth().deleteUser(targetUid);

    const userDocRef = db.collection("users").doc(targetUid);
    batch.delete(userDocRef);

    await batch.commit();

    console.log(`User ${targetUid} and their Firestore document deleted.`);
    return {
      success: true,
      message: "User and associated data deleted successfully.",
    };
  } catch (error) {
    console.error("Error deleting user:", error);
    if (error.code === "auth/user-not-found") {
      throw new functions.https.HttpsError("not-found", "User not found.");
    }
    if (error.code && error.message) {
      throw new functions.https.HttpsError(
          "internal",
          `Firebase Admin SDK error: ${error.code} - ${error.message}`,
          error.details,
      );
    }
    throw new functions.https.HttpsError(
        "internal",
        "Failed to delete user.",
        error.message,
    );
  }
});

exports.getAllUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token.user_role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only administrators can view all users.",
    );
  }

  const {buildingId, role, limit = 100} = data;

  try {
    let query = db.collection("users").orderBy("first_name");

    if (buildingId) {
      query = query.where("building_id", "==", buildingId);
    }

    if (role) {
      query = query.where("user_role", "==", role);
    }

    query = query.limit(limit);

    const snapshot = await query.get();
    const users = [];

    snapshot.forEach((doc) => {
      const userData = doc.data();
      delete userData.password_hash;
      users.push({
        id: doc.id,
        ...userData,
      });
    });

    return {users, count: users.length};
  } catch (error) {
    console.error("Error getting users:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve users.",
        error.message,
    );
  }
});

exports.updateUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {targetUid, updateData} = data;

  if (!targetUid || !updateData) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing target UID or update data.",
    );
  }

  const isAdmin = context.auth.token.user_role === "admin";
  const isSelfUpdate = context.auth.uid === targetUid;

  if (!isAdmin && !isSelfUpdate) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "You can only update your own profile or be an admin.",
    );
  }

  try {
    const allowedFields = [
      "first_name",
      "last_name",
      "phone_number",
      "department",
      "building_id",
      "unit_id",
    ];

    if (isAdmin) {
      allowedFields.push("user_role", "status");
    }

    const filteredUpdateData = {};
    Object.keys(updateData).forEach((key) => {
      if (allowedFields.includes(key)) {
        filteredUpdateData[key] = updateData[key];
      }
    });

    filteredUpdateData.updated_at =
    admin.firestore.FieldValue.serverTimestamp();

    await db.collection("users").doc(targetUid).update(filteredUpdateData);

    if (filteredUpdateData.user_role && isAdmin) {
      await admin.auth().setCustomUserClaims(targetUid, {
        user_role: filteredUpdateData.user_role,
      });
    }

    console.log(`User ${targetUid} profile updated`);
    return {success: true, message: "Profile updated successfully"};
  } catch (error) {
    console.error("Error updating user profile:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Failed to update user profile.",
        error.message,
    );
  }
});

exports.getUserStatistics = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token.user_role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only administrators can view user statistics.",
    );
  }

  try {
    const usersSnapshot = await db.collection("users").get();
    const stats = {
      total: 0,
      byRole: {admin: 0, staff: 0, tenant: 0},
      byStatus: {active: 0, suspended: 0},
      byBuilding: {},
    };

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      stats.total++;

      if (userData.user_role) {
        stats.byRole[userData.user_role] =
        (stats.byRole[userData.user_role] || 0) + 1;
      }

      if (userData.status) {
        stats.byStatus[userData.status] =
        (stats.byStatus[userData.status] || 0) + 1;
      }

      if (userData.building_id) {
        const buildingId = userData.building_id;
        stats.byBuilding[buildingId] =
        (stats.byBuilding[buildingId] || 0) + 1;
      }
    });

    return stats;
  } catch (error) {
    console.error("Error getting user statistics:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve user statistics.", error.message,
    );
  }
});
