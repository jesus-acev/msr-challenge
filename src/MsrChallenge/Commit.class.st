Class {
	#name : #Commit,
	#superclass : #Object,
	#instVars : [
		'sha',
		'message',
		'author',
		'chatgptSharings'
	],
	#category : #MsrChallenge
}

{ #category : #'as yet unclassified' }
Commit class >> fromDict: dict [
    | c |
    c := self new.
    c instVarNamed: 'sha' put: (dict at: 'Sha' ifAbsent: [ nil ]).
    c instVarNamed: 'message' put: (dict at: 'Message' ifAbsent: [ '' ]).
    c instVarNamed: 'author' put: (dict at: 'Author' ifAbsent: [ '' ]).
    c instVarNamed: 'chatgptSharings' put: (dict at: 'ChatgptSharing' ifAbsent: [ #() ]).
    ^ c
]

{ #category : #'as yet unclassified' }
Commit class >> gtViewListOn: aView forCollection: aCollection [
    <gtView>
    ^ aView list
        title: 'Commits';
        items: aCollection;
        itemText: [ :c | c sha , ' - ' , c commitPrefix ];
        whenSelected: [ :elem :view | view setObject: elem ].
]

{ #category : #'as yet unclassified' }
Commit >> author [     ^ author.
]

{ #category : #'as yet unclassified' }
Commit >> chatgptSharings [  ^ chatgptSharings.
]

{ #category : #'as yet unclassified' }
Commit >> commitPrefix [
    "Extrae el prefijo del mensaje: fix:, add:, docs:, bug:, etc."
    | lower |
    message ifNil: [ ^ 'unknown' ].
    lower := message asLowercase.

    #( 'fix' 'add' 'docs' 'bug' 'feat' 'refactor' 'chore' 'update' 'build' 'ci' 'style' 'test'  'perf') 
        do: [ :p | (lower beginsWith: p) ifTrue: [ ^ p ] ].

    ^ 'other'
]

{ #category : #'as yet unclassified' }
Commit >> gtViewDetailsOn: aView [
    <gtView>
    ^ aView columnedList
        title: 'Commit details';
        items: {
            'SHA' -> sha.
            'Author' -> author.
            'Message' -> message.
            'Prefix' -> self commitPrefix.
            'ChatGPT Sharings' -> chatgptSharings size asString }.
]

{ #category : #'as yet unclassified' }
Commit >> mentionsTechnologies [
    "Retorna un diccionario indicando qué tecnologías se mencionan al menos una vez."
    | msg lower techs result |
    
    message ifNil: [ ^ Dictionary new ].
	
    msg := message asString.
    lower := msg asLowercase.

    techs := {
        'github'.
        'python'.
        'docker'.
        'ci/cd'.
        'api'.
        'ui'
    }.

    result := Dictionary new.

    techs do: [ :t |
        (lower includesSubstring: t asLowercase)
            ifTrue: [ result at: t put: true ]
            ifFalse: [ result at: t put: false ].
    ].

    ^ result

]

{ #category : #'as yet unclassified' }
Commit >> message [    ^ message.
]

{ #category : #'as yet unclassified' }
Commit >> occurrencesOfTechnology: aString [
	    | lower pattern index count |
	    message ifNil: [ ^ 0 ].
	
	    lower := message asLowercase.
	    pattern := aString asLowercase.
	
	    index := 1.
	    count := 0.
	
	    [ 
	        index := lower findString: pattern startingAt: index.
	        index > 0
	    ] whileTrue: [
	        count := count + 1.
	        index := index + pattern size.  "avanzar para evitar contar la misma aparición"
	    ].
	
	    ^ count
	
]

{ #category : #'as yet unclassified' }
Commit >> sha [        ^ sha.
]

{ #category : #'as yet unclassified' }
Commit >> totalTechnologyMentionsAt: tech [
    ^ self occurrencesOfTechnology: tech

]
