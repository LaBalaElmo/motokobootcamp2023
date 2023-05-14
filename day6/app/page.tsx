'use client'
import { useState } from "react"
import {makeBackendActor} from "./service/actors"

export default function Home() {
  const [greet, setGreet] = useState<String>("");

  const getGreet = async () => {
    const actor: any = makeBackendActor();
    const getGreeting = await actor.greeting("Rodrigo")
    setGreet(getGreeting)
  }

  return (
    <main>
      <h1>Este es un titulo de prueba</h1>
      <p>Este mensaje generado por motoko es: {greet}</p>
      <button onClick={getGreet}> Click Aqui</button>
    </main>
  )
}
