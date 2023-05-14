import {createActor, canisterId} from "../../src/declarations/backend";

export const makeActor = (canisterId: any, createActor: any) => {
    return createActor(canisterId, {
      agentOptions: {
        host: process.env.NEXT_PUBLIC_IC_HOST
      }
    })
  }
  
  export function makeBackendActor() {
    return makeActor(canisterId, createActor)
  }