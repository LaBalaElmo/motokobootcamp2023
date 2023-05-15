'use client'
import Image from "next/image"
import { useState } from "react"
import {makeBackendActor} from "../service/actors"
import styles from  "./calculator.module.css"

export default function Home() {
  const [display, setDisplay] = useState<String>("");
  const [oldCalculator, setOldCalculator] = useState<boolean>(true)
  const [blockKey, setBlockKey] = useState<boolean>(false)
  const [gif, setGif] = useState<boolean>(false)

  const buttonNumber = async (values: string) => {
    if(!blockKey){
      setDisplay(display + values)
    }
  }

  const buttonEqual = async () => {
    const actor: any = makeBackendActor();
    if(display == "987654321+-"){
      setGif(true)
      setDisplay("")
      return;
    }else{
      setGif(false)
    }
    if(oldCalculator){
      const splitedOperation: String[] = display.replaceAll("-", "+-").split("+");
      const numbersArray: number[] = [];
      for(const i of splitedOperation){
        let ans = +i;
        if(i.includes("*") || i.includes("/")){
          ans = 0;
          let aux = i.split("*")
          let res: String[][] = [];
          for(const f of aux){
            res.push(f.split("/"))
          }
          for(let index = 0; index < res.length; index++ ){
            if(res[index].length > 1){
              let divAux = 0;
              for(const f of res[index]){
                if(divAux == 0){
                  divAux = +f;
                }else{
                  if(+f == 0){
                    setBlockKey(true)
                    setDisplay("Cannot divide by zero")
                    return
                  }
                  divAux = await actor.div(divAux, +f);
                }
              }
              res[index]=[divAux.toString()]
            }
          }
          for(const f of res){
            if(ans == 0){
              ans = +f;
            }else{
              ans = await actor.mul(ans, +f);
            }
          }
        }
        console.log(ans)
        numbersArray.push(ans)
      }
      if(!numbersArray.includes(NaN)){
        setDisplay(await(await actor.generalOperation(numbersArray)))
      }else{
        setBlockKey(true)
        setDisplay("Syntax Error")
      }
    }else{
      if(display.includes("+")){
        const numbers = display.split("+")
        setDisplay(await actor.add(+numbers[0], +numbers[1]))
      }else if(display.includes("-")){
        const numbers = display.split("-")
        setDisplay(await actor.sub(+numbers[0], +numbers[1]))
      }else if(display.includes("*")){
        const numbers = display.split("*")
        setDisplay(await actor.mul(+numbers[0], +numbers[1]))
      }else if(display.includes("/")){
        const numbers = display.split("/")
        setDisplay(await actor.div(+numbers[0], +numbers[1]))
      }else{
        setDisplay(display)
      }
    }
  }

  const clear = async () => {
    setGif(false)
    setBlockKey(false)
    setDisplay("")
  }

  const deleteOne = async () => {
    if(!blockKey){
      setDisplay(display.substring(0,display.length-1))
    }
  }

  return (
    <main>
      <div>
        <h1 style={{fontFamily: "cursive", fontSize: "50px"}} className={styles.center}>Calculator</h1>
        <div className={styles.calculator}>
          <input type="text" id="result" readOnly value={display.toString()}/>
          <div className={styles.buttons}>
              <button onClick={() => buttonNumber("7")} style={{background: "#707070"}}>7</button>
              <button onClick={() => buttonNumber("8")} style={{background: "#707070"}}>8</button>
              <button onClick={() => buttonNumber("9")} style={{background: "#707070"}}>9</button>
              <button onClick={() => buttonNumber("+")} style={{background: "#b0b0b0"}}>+</button>
              <button onClick={() => buttonNumber("4")} style={{background: "#707070"}}>4</button>
              <button onClick={() => buttonNumber("5")} style={{background: "#707070"}}>5</button>
              <button onClick={() => buttonNumber("6")} style={{background: "#707070"}}>6</button>
              <button onClick={() => buttonNumber("-")} style={{background: "#b0b0b0"}}>-</button>
              <button onClick={() => buttonNumber("1")} style={{background: "#707070"}}>1</button>
              <button onClick={() => buttonNumber("2")} style={{background: "#707070"}}>2</button>
              <button onClick={() => buttonNumber("3")} style={{background: "#707070"}}>3</button>
              <button onClick={() => buttonNumber("*")} style={{background: "#b0b0b0"}}>*</button>
              <button onClick={() => buttonNumber("0")} style={{background: "#707070"}}>0</button>
              <button onClick={() => buttonNumber(".")} style={{background: "#707070"}}>.</button>
              <button onClick={buttonEqual} style={{background: "#f69700", alignSelf: "flex-end"}}>=</button>
              <button onClick={() => buttonNumber("/")} style={{background: "#b0b0b0"}}>/</button>
              <button onClick={clear} style={{background: "#e23148"}}>C</button>
              <button onClick={deleteOne} style={{background: "#e23148"}}>DEL</button>
          </div>
        </div>
        <div className={styles.center}>
          {gif?
            <div>
              <p style={{fontSize: "20px", color:"white", padding: "40px"}}>
                Press button &quot;C&quot; or &quot;=&quot; to stop the music and remove the gif
              </p>
              <Image 
                src={"/dance.gif"} 
                alt={"dance"}
                width="500"
                height={"30"}
              >
              </Image>
              <audio
              controls autoPlay
              src="/lean.mp3">
              </audio>
            </div>:
            <div>
              <p style={{fontSize: "20px", color:"white", padding: "40px"}}>
                Type &quot;987654321+-&quot; in the calculator and then press &quot;=&quot; to see an easter egg
              </p>
            </div>
          }
        </div>
      </div>
    </main>
  )
}
