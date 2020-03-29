//
//  AuthService.swift
//  CognitoAuthentication
//
//  Created by Gustavo Tavares on 09.03.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import AWSCore
import AWSMobileClient

struct SignUpDetails {
    let username: String
    let password: String
    let email: String?
    let phone: String?
}

struct AuthDetails {
    let username: String
    let password: String
    let claims: [String] = []
}

enum AuthStatus {
    case signedOff
    case signedIn
    case signedInAsGuest
    case waitingConfirmationCode
    case waitingMFACode
    case waitingPasswordChange
    case needTokenRefresh
    case notImplemented
}

enum AuthError: Error {
    case simpleError, complexError
}

class AuthService {
    
    typealias AuthClosure = (Result<AuthStatus,AuthError>) -> Void
    
    public static let shared = AuthService()

    public var userName: String? { self.client.username }
    public var userId: String? { self.client.identityId }
    public private (set) var status: AuthStatus = AuthStatus.signedOff {
        didSet { print(self.status) }
    }
    
    private let client: AWSMobileClient = AWSMobileClient.default()
    
    private init() {
    
        self.client.addUserStateListener(self) { (state, attributes) in
            
            switch (state) {
            case .guest:
                self.status = .signedInAsGuest
                
            case .signedIn:
                self.status = .signedIn
                
            case .signedOut:
                self.status = .signedOff
                
            case .signedOutUserPoolsTokenInvalid:
                self.status = .needTokenRefresh
                
            case .signedOutFederatedTokensInvalid:
                self.status = .needTokenRefresh
            
            case .unknown:
                self.status = .signedOff
                
            }
            
        }
    
    }
    
    deinit {
        self.client.removeUserStateListener(self)
    }

    public func signUp(details: SignUpDetails, completing: @escaping AuthClosure) -> Void {
        
        var userAttributes: [String: String] = [:]
        if let phone = details.phone { userAttributes["phone"] = phone }
        
        self.client.signUp(
            username: details.username,
            password: details.password,
            userAttributes: userAttributes
        ) {(result, error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            guard let result = result else {
                completing(Result.failure(AuthError.simpleError))
                return
            }
            
            let response = self.helpProcessingSignUpConfirmation(state: result.signUpConfirmationState)
            completing(response)
            
        }
        
    }
    
    public func signIn(username: String, password: String, completing: @escaping AuthClosure) -> Void {
        
        self.client.signIn(username: username, password: password) { (result, error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            guard let result = result else {
                completing(Result.failure(AuthError.simpleError))
                return
            }
            
            let response = self.helpProcessingSignIn(state: result.signInState)
            completing(response)
            
        }
        
    }
    
    public func sendConfirmationCode(username: String, code: String, completing: @escaping AuthClosure) -> Void {
        
        self.client.confirmSignUp(username: username, confirmationCode: code) { (result, error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            guard let result = result else {
                completing(Result.failure(AuthError.simpleError))
                return
            }
            
            let response = self.helpProcessingSignUpConfirmation(state: result.signUpConfirmationState)
            completing(response);
            
        }
        
    }
    
    public func requestNewConfirmationCode(username: String, completing: @escaping AuthClosure) -> Void {
        
        self.client.resendSignUpCode(username: username) { (result, error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            guard let result = result else {
                completing(Result.failure(AuthError.simpleError))
                return
            }
            
            let response = self.helpProcessingSignUpConfirmation(state: result.signUpConfirmationState)
            completing(response)
            
        }
        
    }
    
    public func sendMFACode(code: String, completing: @escaping AuthClosure) -> Void {
    
        self.confirmSignIn(code: code, completing: completing)
    
    }
    
    public func sendPasswordChange(newpassword: String, completing: @escaping AuthClosure) -> Void {
        
        self.confirmSignIn(code: newpassword, completing: completing)
        
    }
    
    public func requestPasswordChange(completing: @escaping AuthClosure) -> Void { }
    
    public func signOut(completing: @escaping AuthClosure) -> Void {
        
        self.client.signOut { (error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            completing(Result.success(.signedOff))
            
        }
        
    }
    
    private func confirmSignIn(code: String, completing: @escaping AuthClosure) -> Void {
        
        self.client.confirmSignIn(challengeResponse: code) { (result, error) in
            
            guard error == nil else {
                completing(Result.failure(AuthError.complexError))
                return
            }
            
            guard let result = result else {
                completing(Result.failure(AuthError.simpleError))
                return
            }
            
            let response = self.helpProcessingSignIn(state: result.signInState)
            completing(response)
            
        }
        
    }
    
    private func helpProcessingSignUpConfirmation(state: SignUpConfirmationState) -> Result<AuthStatus, AuthError> {
        
        switch (state) {
            
        case .confirmed:
            self.status = .signedIn
            return Result.success(.signedIn)
            
        case .unconfirmed:
            self.status = .waitingConfirmationCode
            return Result.success(.waitingConfirmationCode)
            
        case .unknown:
            self.status = .signedOff
            return Result.failure(AuthError.simpleError)
            
        }
        
    }
    
    private func helpProcessingSignIn(state: SignInState) -> Result<AuthStatus, AuthError> {
        
        switch (state) {
            
        case .signedIn:
            self.status = .signedIn
            return Result.success(.signedIn)
            
        case .newPasswordRequired:
            self.status = .waitingPasswordChange
            return Result.success(.waitingPasswordChange)
            
        case .devicePasswordVerifier:
            self.status = .waitingMFACode
            return Result.success(.waitingMFACode)
            
        case .deviceSRPAuth:
            self.status = .waitingPasswordChange
            return Result.success(.waitingPasswordChange)
            
        case .customChallenge:
            self.status = .notImplemented
            return Result.failure(AuthError.simpleError)
            
        case .adminNoSRPAuth:
            self.status = .notImplemented
            return Result.failure(AuthError.simpleError)
            
        case .passwordVerifier:
            self.status = .notImplemented
            return Result.failure(AuthError.simpleError)
            
        case .smsMFA:
            self.status = .waitingMFACode
            return Result.success(.waitingMFACode)
            
        case .unknown:
            self.status = .signedOff
            return Result.failure(AuthError.simpleError)
            
        }
        
    }
    
}
