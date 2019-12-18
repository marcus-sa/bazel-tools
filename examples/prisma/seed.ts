import { Photon } from './index';

(async() => {
  const photon = new Photon();
  try {
    await photon.connect();
  } catch (err) {
    // TODO:
    /*
      TODO: Figure out why this error occurs
      PhotonError: undefined target="exit" timestamp="2019-12-18T00:05:11.301Z" fields={"message":"1"}
        at NodeEngine.engineReady (examples/prisma/client/runtime/index.js:3533:23)
        at examples/prisma/client/runtime/index.js:3456:21
     */
    console.log(err);
  }
})();
