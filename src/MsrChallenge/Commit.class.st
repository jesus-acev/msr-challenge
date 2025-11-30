Class {
	#name : 'Commit',
	#superclass : 'Object',
	#instVars : [
		'sha',
		'message',
		'author',
		'chatgptSharings'
	],
	#category : 'MsrChallenge',
	#package : 'MsrChallenge'
}

{ #category : 'as yet unclassified' }
Commit class >> fromDict: dict [
    | c |
    c := self new.
    c instVarNamed: 'sha' put: (dict at: 'Sha' ifAbsent: [ nil ]).
    c instVarNamed: 'message' put: (dict at: 'Message' ifAbsent: [ '' ]).
    c instVarNamed: 'author' put: (dict at: 'Author' ifAbsent: [ '' ]).
    c instVarNamed: 'chatgptSharings' put: (dict at: 'ChatgptSharing' ifAbsent: [ #() ]).
    ^ c
]

{ #category : 'as yet unclassified' }
Commit class >> gtViewListOn: aView forCollection: aCollection [
    <gtView>
    ^ aView list
        title: 'Commits';
        items: aCollection;
        itemText: [ :c | c sha , ' - ' , c commitPrefix ];
        whenSelected: [ :elem :view | view setObject: elem ].
]

{ #category : 'as yet unclassified' }
Commit >> author [     ^ author.
]

{ #category : 'as yet unclassified' }
Commit >> chatgptSharings [  ^ chatgptSharings.
]

{ #category : 'as yet unclassified' }
Commit >> commitPrefix [
    "Extrae el prefijo del mensaje: fix:, add:, docs:, bug:, etc."
    | lower |
    message ifNil: [ ^ 'unknown' ].
    lower := message asLowercase.

    #( 'fix' 'add' 'docs' 'bug' 'feat' 'refactor' 'chore' 'update' 'build' 'ci' 'style' 'test'  'perf') 
        do: [ :p | (lower beginsWith: p) ifTrue: [ ^ p ] ].

    ^ 'other'
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
Commit >> message [    ^ message.
]

{ #category : 'as yet unclassified' }
Commit >> sha [        ^ sha.
]
