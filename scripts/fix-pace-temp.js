/**
 * paceTemp가 36.5인 active 유저를 37.0으로 일괄 수정 (디스커버리 노출용)
 *
 * Usage: npm run fix:pace-temp
 * (serviceAccountKey.json 또는 GOOGLE_APPLICATION_CREDENTIALS 필요)
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const projectRoot = path.join(__dirname, '..');
const serviceAccountPath = path.join(projectRoot, 'serviceAccountKey.json');
const credPathFromEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;

const ACTIVE_PACE_TEMP = 37.0;

function initFirebase() {
  if (credPathFromEnv && fs.existsSync(credPathFromEnv)) {
    admin.initializeApp({
      credential: admin.credential.cert(require(credPathFromEnv)),
    });
    return;
  }

  if (fs.existsSync(serviceAccountPath)) {
    admin.initializeApp({
      credential: admin.credential.cert(require(serviceAccountPath)),
    });
    return;
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

async function main() {
  initFirebase();
  const db = admin.firestore();

  const snap = await db.collection('users').get();
  const targets = snap.docs.filter((doc) => {
    const data = doc.data();
    return data.status === 'active' && (data.paceTemp ?? 0) <= 36.5;
  });

  if (targets.length === 0) {
    console.log('수정할 유저가 없습니다.');
    return;
  }

  const batch = db.batch();
  targets.forEach((doc) => {
    batch.update(doc.ref, { paceTemp: ACTIVE_PACE_TEMP });
    console.log(`  ${doc.id} (${doc.data().name}) → paceTemp ${ACTIVE_PACE_TEMP}`);
  });

  await batch.commit();
  console.log(`\n완료: ${targets.length}명 수정됨`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
