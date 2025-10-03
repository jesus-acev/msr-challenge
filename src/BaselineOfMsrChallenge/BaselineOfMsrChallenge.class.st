Class {
	#name : #BaselineOfMsrChallenge,
	#superclass : #BaselineOf,
	#category : #BaselineOfMsrChallenge
}

{ #category : #loading }
BaselineOfMsrChallenge class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'msr-challenge' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfMsrChallenge >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'MsrChallenge'
		]
]
