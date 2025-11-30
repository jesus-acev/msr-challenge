Class {
	#name : #JsonGraph,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#category : 'MsrChallenge-MSRChallenge-Model'
}

{ #category : #accessing }
JsonGraph class >> fileName [
    ^ self new from: fileName
]

{ #category : #accessing }
JsonGraph class >> fromFile: fileName [
    ^ self new from: fileName

]

{ #category : #'as yet unclassified' }
JsonGraph >> data [
    ^ data

]

{ #category : #'as yet unclassified' }
JsonGraph >> data: anObject [
    data := anObject

]

{ #category : #accessing }
JsonGraph >> from: fileName [
    | fileReference jsonString jsonObject |
    
    fileReference := fileName asFileReference.
    jsonString := fileReference contents.
    
    jsonObject := STONJSON fromString: jsonString.
    
    data := jsonObject.
    
    "Retorna el mismo objeto (self)"
    ^ self
]
