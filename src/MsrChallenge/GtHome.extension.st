Extension { #name : 'GtHome' }

{ #category : '*MsrChallenge' }
GtHome >> msrChallengeSection [
	<gtHomeSection>
	^ GtHomeStartPageSection new
		title: 'MsrChallenge';
		description: 'Experimentando con GT';
		databaseName: 'jesus-acev/msr-challenge/lepiter';
		startPageName: 'Pagina de inicio';
		priority: 8
]
