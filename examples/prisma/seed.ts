import { Photon } from './index';

(async() => {
  // @ts-ignore
  console.log(process.env);

  const email = 'marcus-sa@outlook.com';
  const photon = new Photon();

  try {
    await photon.connect();

    let user = await photon.users.findOne({
      where: {
        email,
      },
    });

    if (!user) {
      user = await photon.users.create({
        data: {
          email,
        },
      });
    }

    console.log(user);

    await photon.disconnect();
  } catch (err) {
    /*
      TODO: Figure out why this error occurs
      PhotonError: undefined target="exit" timestamp="2019-12-18T00:05:11.301Z" fields={"message":"1"}
        at NodeEngine.engineReady (examples/prisma/client/runtime/index.js:3533:23)
        at examples/prisma/client/runtime/index.js:3456:21
     */
    console.log(err);
  }
})();
