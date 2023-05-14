'use client'
import { useState } from "react"
import {makeBackendActor} from "./service/actors"

export default function Home() {
  const [greet, setGreet] = useState<String>("");
  const [name, setName] = useState<String>("");

  const getGreet = async () => {
    console.log(name)
    const actor: any = makeBackendActor();
    const getGreeting = await actor.greeting(name)
    setGreet(getGreeting)
  }

  const handleChangeName = (event: any) => {
    setName(event.target.value);
  };

  return (
    <main>
      <h1>Este es un titulo de prueba</h1>
      <p>Este mensaje generado por motoko es: {greet}</p>
      <label 
        className="block mb-2 text-sm font-medium text-gray-900 dark:text"
      >
        Name
      </label>
      <input 
        id="name"
        onChange={handleChangeName}
        className="bg-gray-200 border border-gray-400 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
      ></input>
      <button 
        onClick={getGreet} 
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
      > 
        Click Aqui
      </button>
    </main>
  )
}
