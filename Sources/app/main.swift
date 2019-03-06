import Foundation
import Kitura
import KituraStencil
import KituraSession



struct Message : Codable {
	let message: String
	let familyName: String
}

func dateDuJour() -> String {
  let now = Date()
  let dateFormat = DateFormatter()
  dateFormat.dateStyle = .short
  dateFormat.timeStyle = .short
  dateFormat.locale = Locale(identifier: "FR-fr")
  return dateFormat.string(from: now)
}

let router = Router()
var history : [Message] = []
let session = Session(secret: "secret")

router.add(templateEngine: StencilTemplateEngine())
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")])
router.all(middleware: Session(secret: "secret"))

router.get("/") { request, response, next in
  try response.render("index.stencil", context: ["messages": history])
  next()
}

router.post("/") { request, response, next in
  if let body = request.body?.asURLEncoded, let message = body["message"], let familyName = body["familyName"] {
    
    /*
     Algo de cryptage ROT = lettre + index de la lettre + 2premiere lettre du nom de famille
     
     Afin de récupérer l'index de la lettre de l'alphabet il va falloir
     - boucler sur le tableau et la valeur de retour sera l'index
     - retrouner la lettre qui a pour index l'index de base ajouté de l'index de la lettre dans la string + index des deux premieres lettres du nom de famille
     
     */
    let userMessage = message.trimmingCharacters(in: .whitespaces)
    let premiereLettre = familyName.prefix(2)
    let alphabet = "abcdefghijklmnopqrstuvwxyz"
    let arrayMessage = Array(userMessage)
    let premiereLettreArray = Array(premiereLettre)
    let arrayAlph = Array(alphabet)
    var pasFamily = 0
    var pasIndexLetterMessage = 0
    var initialIndex = 0
    var finalPasForEachLetter = 0
    var finalPas = 0
    var cryptLetter = ""
    var cryptMot = ""
    
    //Fonction qui récupére l'index des deux premieres lettres du nom de famille
    //Augmente le pas d'écart de la somme des index des deux lettres
    func getTwoFirstLetterIndex(mot: String) -> Int {
        //Boucle pour récupérer les deux premieres lettres une à une
        for eachLettre in premiereLettreArray {
            //Boucle pour récupérer chaque lettre de l'alphabet
            for aLetter in alphabet {
                //Si les deux lettre correspondent alors le pas = pas + index de la lettre dans l'alphabet + 1 (on compte à partir de 1)
                if aLetter == eachLettre {
                    pasFamily += (arrayAlph.firstIndex(of: eachLettre)!)
                    break
                } else {
                    //print(letter)
                }
            }
        }
        print("Pas du nom de famille : \(pasFamily)")
        return pasFamily
    }
    
    func run(message: String) -> Void {
        //Boucle sur lensemble des lettres du message
        getTwoFirstLetterIndex(mot: String(premiereLettre))
        for mLetter in message {
            //Recupération de l'index pour chaque lettre du message
            pasIndexLetterMessage = getIndexOfCharacterInString(lettre: mLetter)
            print("Pas de l'index pour chaque lettre : \(pasIndexLetterMessage)")
            //Boucle sur l'alphabet
            for aLetter in alphabet {
                //print(letter)
                
                //Si la lettre du message = lettre de l'alphabet, afficher index de la lettre dans l'alphabet
                if aLetter == mLetter {
                    initialIndex = arrayAlph.firstIndex(of: aLetter)!
                    print("Index initial de la lettre \(aLetter) dans l'alphabet : \(initialIndex)")
                    calculPas(pasName: pasFamily, pasIndex: pasIndexLetterMessage, ii: initialIndex)
                    print("Index à aller chercher : \(finalPasForEachLetter)")
                    finalCalcul(finalPasLetter: finalPasForEachLetter)
                    print("Index après modulo : \(finalPas)")
                    print("La lettre a crypté est \(mLetter)")
                    cryptage(pas: finalPas)
                    //print(arrayAlph.firstIndex(of: aLetter)! + 1)
                    break
                } else {
                    //print(letter)
                }
            }
            //print(mLetter)  // s, t, r, i, n, g
        }
    }
    
    //Function qui permet de récupérer les index des lettre dans le mot
    func getIndexOfCharacterInString(lettre: Character) -> Int {
        return arrayMessage.firstIndex(of: lettre)! + 1
    }
    
    func calculPas(pasName: Int, pasIndex: Int, ii: Int) -> Int {
        finalPasForEachLetter = pasName + pasIndex + ii
        return finalPasForEachLetter
    }
    func finalCalcul(finalPasLetter: Int) -> Int {
        finalPas = finalPasLetter % arrayAlph.count
        return finalPas
    }
    func cryptage(pas: Int) -> String {
        for lettre in arrayAlph {
            if arrayAlph.firstIndex(of: lettre) == pas {
                print("La lettre crypté est : \(lettre)")
                cryptLetter = String(lettre)
                cryptMot += String(lettre)
                print("Le mot de base est :\(userMessage) \nLe mot crypté est : \(cryptMot)")
            }
        }
        return cryptLetter
    }
    
    
    
    run(message: userMessage)
    
    

    if message.lengthOfBytes(using: .utf8) == 0 {
      try response.render("index.stencil", context: ["messages": history])
      } else {
        history.append(Message(message: cryptMot, familyName: familyName));
        try response.render("index.stencil", context: ["messages": history])
        print(history)
      }
    } else {
      try response.redirect("/").end()
   }
  next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
