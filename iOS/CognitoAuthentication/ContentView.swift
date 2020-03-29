//
//  ContentView.swift
//  CognitoAuthentication
//
//  Created by Gustavo Tavares on 08.03.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI
import KeyboardObserving
import AWSCore
import AWSMobileClient

struct ContentView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            Spacer()
            Text("Test SignIn")
            Spacer()
            TextField("Nome do Usuário", text: $username)
            TextField("Senha", text: $password)
            Spacer()
            Button(action: self.doLogin) {
                Text("Entrar")
            }
            Spacer()
            
            }.padding().keyboardObserving()
        
    }
    
    private func doLogin() -> Void {

        AWSMobileClient.default().signUp(username: "grstavares@gmail.com",
                                                password: "Abc@123!",
                                                userAttributes: ["phone_number": "+1973123456"]) { (signUpResult, error) in
            if let signUpResult = signUpResult {
                switch(signUpResult.signUpConfirmationState) {
                case .confirmed:
                    print("User is signed up and confirmed.")
                case .unconfirmed:
                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                case .unknown:
                    print("Unexpected case")
                }
            } else if let error = error {
                if let error = error as? AWSMobileClientError {
                    switch(error) {
                    case .usernameExists(let message):
                        print(message)
                    default:
                        break
                    }
                }
                print("\(error)")
                print("\(error.localizedDescription)")
            }
        }
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
