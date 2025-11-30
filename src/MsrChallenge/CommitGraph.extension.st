Extension { #name : #CommitGraph }

{ #category : #'*MsrChallenge' }
CommitGraph >> countMentionsOf: aPrefix in: aText [
    "Cuenta todas las ocurrencias de un prefijo"
    | lowerText lowerPrefix total startIndex |
    
    lowerText := aText asLowercase.
    lowerPrefix := aPrefix asLowercase.
    total := 0.
    startIndex := 1.
    
    [ startIndex <= lowerText size ] whileTrue: [
        | foundIndex |
        foundIndex := lowerText findString: lowerPrefix startingAt: startIndex caseSensitive: false.
        foundIndex = 0 
            ifTrue: [ startIndex := lowerText size + 1 ]
            ifFalse: [ 
                total := total + 1.
                startIndex := foundIndex + lowerPrefix size.
            ].
    ].
    
    ^ total
]

{ #category : #'*MsrChallenge' }
CommitGraph >> extractConversationTextFrom: aCommit [
    "Extrae texto de las conversaciones de ChatGPT"
    | parts chatgptSharings |
    
    parts := OrderedCollection new.
    
    "Mensaje del commit"
    parts add: (aCommit at: 'Message' ifAbsent: [ '' ]).
    
    "Conversaciones de ChatGPT"
    chatgptSharings := aCommit at: 'ChatgptSharing' ifAbsent: [ #() ].
    
    chatgptSharings do: [ :sharing |
        "Título de la conversación"
        parts add: (sharing at: 'Title' ifAbsent: [ '' ]).
        
        "Conversaciones individuales"
        (sharing at: 'Conversations' ifAbsent: [ #() ]) do: [ :conv |
            parts add: (conv at: 'Prompt' ifAbsent: [ '' ]).
            parts add: (conv at: 'Answer' ifAbsent: [ '' ]).
            
            "Código"
            (conv at: 'ListOfCode' ifAbsent: [ #() ]) do: [ :codeBlock |
                parts add: (codeBlock at: 'Content' ifAbsent: [ '' ]).
            ].
        ].
    ].
    
    "Unir todas las partes con espacio"
    ^ ' ' join: parts
]
