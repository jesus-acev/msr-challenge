Class {
	#name : #DiscussionGraph,
	#superclass : #Object,
	#instVars : [
		'discussions',
		'fileName'
	],
	#category : 'MsrChallenge-Model'
}

{ #category : #'as yet unclassified' }
DiscussionGraph class >> fromFile: aFileName [
    "Crea una instancia de DiscussionGraph desde un archivo JSON"
    ^ self new from: aFileName
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> countAllMentionsOf: aTechnology [
    "Cuenta todas las ocurrencias de la tecnología"
    | total techLower |
    
    total := 0.
    techLower := aTechnology asLowercase.
    
    discussions do: [ :disc |
        | text startIndex |
        text := ((disc at: 'Title' ifAbsent: [ '' ]), ' ', 
                (disc at: 'Body' ifAbsent: [ '' ])) asLowercase.
        
        startIndex := 1.
        [ startIndex <= text size ] whileTrue: [
            | foundIndex |
            foundIndex := text findString: techLower startingAt: startIndex caseSensitive: false.
            foundIndex = 0 
                ifTrue: [ startIndex := text size + 1 ]
                ifFalse: [ 
                    total := total + 1.
                    startIndex := foundIndex + techLower size.
                ].
        ].
    ].
    
    ^ total
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> countDiscussionsContaining: aTechnology [
    "Cuenta en cuántas discusiones aparece al menos una vez"
    | count techLower |
    
    count := 0.
    techLower := aTechnology asLowercase.
    
    discussions do: [ :disc |
        | text |
        text := ((disc at: 'Title' ifAbsent: [ '' ]), ' ', 
                 (disc at: 'Body' ifAbsent: [ '' ])) asLowercase.
        (text includesSubstring: techLower) ifTrue: [ count := count + 1 ].
    ].
    
    ^ count
    
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> countMentionsOf: aTechnology in: aText [
    "Cuenta las menciones de una tecnología en el texto - VERSIÓN OPTIMIZADA"
    | lowerText lowerTech count startIndex |
    
    lowerText := aText asLowercase.
    lowerTech := aTechnology asLowercase.
    count := 0.
    startIndex := 1.
    
    "Buscar todas las ocurrencias"
    [ startIndex <= lowerText size ] whileTrue: [
        | foundIndex |
        foundIndex := lowerText 
            findString: lowerTech 
            startingAt: startIndex 
            caseSensitive: false.
        
        foundIndex = 0 
            ifTrue: [ startIndex := lowerText size + 1 ]  "Salir del loop"
            ifFalse: [ 
                count := count + 1.
                startIndex := foundIndex + lowerTech size.  "Continuar después de la palabra encontrada"
            ].
    ].
    
    ^ count
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> countTechnology: aTechnology [
    "Cuenta menciones de una tecnología en TODAS las discusiones"
    | total techLower |
    
    total := 0.
    techLower := aTechnology asLowercase.
    
    discussions do: [ :disc |
        | title body |
        
        "Solo buscar en Title y Body (simple)"
        title := (disc at: 'Title' ifAbsent: [ '' ]) asLowercase.
        body := (disc at: 'Body' ifAbsent: [ '' ]) asLowercase.
        
        "Si contiene la tecnología, sumar 1"
        (title includesSubstring: techLower) ifTrue: [ total := total + 1 ].
        (body includesSubstring: techLower) ifTrue: [ total := total + 1 ].
    ].
    
    ^ total
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> discussionCount [
    "Retorna el número total de discusiones"
    ^ discussions size
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> discussions [
    "Retorna la colección de discusiones"
    ^ discussions
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> extractAllTextFrom: aDiscussion [
    "Extrae todo el texto relevante de una discusión - VERSIÓN SIMPLIFICADA"
    | parts |
    
    parts := OrderedCollection new.
    
    "Título"
    parts add: (aDiscussion at: 'Title' ifAbsent: [ '' ]).
    
    "Cuerpo"
    parts add: (aDiscussion at: 'Body' ifAbsent: [ '' ]).
    
    "Conversaciones de ChatGPT"
    (aDiscussion at: 'ChatgptSharing' ifAbsent: [ #() ]) do: [ :sharing |
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

{ #category : #'as yet unclassified' }
DiscussionGraph >> extractChatGPTConversationsFrom: aDiscussion into: aStream [
    "Extrae texto de las conversaciones de ChatGPT"
    | chatgptSharings |
    
    chatgptSharings := aDiscussion at: 'ChatgptSharing' ifAbsent: [ #() ].
    
    chatgptSharings do: [ :sharing |
        | conversations |
        
        "Título de la conversación"
        aStream 
            nextPutAll: (sharing at: 'Title' ifAbsent: [ '' ]); 
            space.
        
        "Conversaciones individuales"
        conversations := sharing at: 'Conversations' ifAbsent: [ #() ].
        conversations do: [ :conv |
            "Prompt"
            aStream 
                nextPutAll: (conv at: 'Prompt' ifAbsent: [ '' ]); 
                space.
            
            "Answer"
            aStream 
                nextPutAll: (conv at: 'Answer' ifAbsent: [ '' ]); 
                space.
            
            "Código si existe"
            self extractCodeFrom: conv into: aStream.
        ].
    ]
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> extractCodeFrom: aConversation into: aStream [
    "Extrae código de los bloques de código"
    | listOfCode |
    
    listOfCode := aConversation at: 'ListOfCode' ifAbsent: [ #() ].
    
    listOfCode do: [ :codeBlock |
        aStream 
            nextPutAll: (codeBlock at: 'Content' ifAbsent: [ '' ]); 
            space.
    ]
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> fileName [
    "Retorna el nombre del archivo cargado"
    ^ fileName
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> from: aFileName [
    "Lee el archivo JSON y carga las discusiones"
    | fileContent jsonData sources |
    
    "Guarda el nombre del archivo"
    fileName := aFileName.
    
    "Lee el contenido del archivo"
    fileContent := aFileName asFileReference contents.
    
    "Parsea el JSON usando STON"
    jsonData := STONJSON fromString: fileContent.
    
    "Extrae el array de Sources"
    sources := jsonData at: 'Sources' ifAbsent: [ #() ].
    
    "Guarda las discusiones"
    discussions := sources asOrderedCollection.
    
    "Retorna self para inspección"
    ^ self
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> gtTechFrequencyFor: aView [
    <gtView>
    ^ aView columnedList
        title: 'Tecnologias column';
        priority: 1;
        items: [ self technologyMentionsData ];
        column: 'Technology' text: [ :item | item at: #tech ] width: 120;
        column: 'Count' text: [ :item | item at: #count ] width: 80
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> gtTechVisualizationFor: aView [
    <gtView>
    ^ aView explicit
        title: 'Tecnologias View';
        priority: 1;
        stencil: [ self visualizeTechnologies ]
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> initialize [
    super initialize.
    discussions := OrderedCollection new.
    fileName := ''
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> repositoryNames [
    "Retorna una colección única de nombres de repositorios"
    ^ (discussions collect: [ :disc | disc at: 'RepoName' ifAbsent: [ 'Unknown' ] ]) asSet
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> technologyMentions [
    "Analiza la frecuencia de menciones de tecnologías específicas - VERSIÓN OPTIMIZADA"
    | technologies results |
    
    "Define las tecnologías a buscar"
    technologies := #('GitHub' 'Python' 'Docker' 'CICD' 'API' 'UI').
    
    "Inicializa el diccionario de resultados"
    results := Dictionary new.
    technologies do: [ :tech | results at: tech put: 0 ].
    
    "Procesa cada discusión"
    discussions do: [ :discussion |
        | textToSearch |
        textToSearch := self extractAllTextFrom: discussion.
        
        "Cuenta menciones de cada tecnología"
        technologies do: [ :tech |
            | mentions |
            mentions := self countMentionsOf: tech in: textToSearch.
            results at: tech put: (results at: tech) + mentions.
        ].
    ].
    
    ^ results
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> technologyMentionsData [
    "Retorna una colección simple con tecnología y conteo"
    | technologies result |
    
    technologies := #('GitHub' 'Python' 'Docker' 'CICD' 'API' 'UI').
    result := OrderedCollection new.
    
    technologies do: [ :tech |
        | count |
        count := self countTechnology: tech.
        
        result add: (Dictionary new
            at: #tech put: tech;
            at: #count put: count;
            yourself).
    ].
    
    "Ordenar de mayor a menor"
    ^ result sorted: [ :a :b | (a at: #count) > (b at: #count) ]
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> technologyVisualizationData [
    "Retorna datos para visualización con colores"
    | technologies result colors |
    
    technologies := #('GitHub' 'Python' 'Docker' 'CICD' 'API' 'UI').
    
    "Colores RGB distintos para cada tecnología"
    colors := {
        Color fromHexString: '#FF6B6B'.  "Rojo - GitHub"
        Color fromHexString: '#4ECDC4'.  "Turquesa - Python"
        Color fromHexString: '#45B7D1'.  "Azul - Docker"
        Color fromHexString: '#FFA07A'.  "Naranja - CICD"
        Color fromHexString: '#98D8C8'.  "Verde agua - API"
        Color fromHexString: '#F7DC6F'.  "Amarillo - UI"
    }.
    
    result := OrderedCollection new.
    
    technologies doWithIndex: [ :tech :index |
        | discussionCount totalMentions |
        
        discussionCount := self countDiscussionsContaining: tech.
        totalMentions := self countAllMentionsOf: tech.
        
        result add: (Dictionary new
            at: #tech put: tech;
            at: #color put: (colors at: index);
            at: #discussionCount put: discussionCount;
            at: #totalMentions put: totalMentions;
            yourself).
    ].
    
    "Ordenar por total de menciones (de mayor a menor)"
    ^ result sorted: [ :a :b | (a at: #totalMentions) > (b at: #totalMentions) ]
]

{ #category : #'as yet unclassified' }
DiscussionGraph >> visualizeTechnologies [
    "Visualiza tecnologías como rectángulos de colores"
    | container colors yPosition |
    
    container := BlElement new
        layout: BlLinearLayout vertical;
        constraintsDo: [ :c |
            c horizontal fitContent.
            c vertical fitContent ];
        padding: (BlInsets all: 20);
        yourself.
    
    "Colores RGB para cada tecnología"
    colors := Dictionary new
        at: 'GitHub' put: (Color r: 0.2 g: 0.4 b: 0.8);      "Azul"
        at: 'Python' put: (Color r: 0.2 g: 0.6 b: 0.9);      "Azul claro"
        at: 'Docker' put: (Color r: 0.0 g: 0.5 b: 0.8);      "Cyan"
        at: 'CICD' put: (Color r: 0.9 g: 0.5 b: 0.2);        "Naranja"
        at: 'API' put: (Color r: 0.3 g: 0.7 b: 0.3);         "Verde"
        at: 'UI' put: (Color r: 0.8 g: 0.3 b: 0.5);          "Rosa"
        yourself.
    
    yPosition := 0.
    
    #('GitHub' 'Python' 'Docker' 'CICD' 'API' 'UI') do: [ :tech |
        | discussionCount mentionCount width height techElement label |
        
        "Cuántas discusiones contienen esta tech (ancho)"
        discussionCount := self countDiscussionsContaining: tech.
        
        "Cuántas veces total aparece (alto)"
        mentionCount := self countAllMentionsOf: tech.
        
        "Dimensiones: ancho por discusiones, alto por menciones"
        width := (discussionCount * 30) max: 50.
        height := (mentionCount * 10) max: 30.
        
        "Crear rectángulo"
        techElement := BlElement new
            geometry: BlRectangleGeometry new;
            size: width @ height;
            background: (colors at: tech);
            border: (BlBorder paint: Color black width: 2);
            margin: (BlInsets all: 10);
            yourself.
        
        "Label con información"
        label := BlTextElement new
            text: (tech asRopedText 
                fontSize: 14; 
                foreground: Color white;
                bold);
            yourself.
        
        techElement addChild: label.
        label relocate: 5 @ 5.
        
        "Tooltip al pasar el mouse"
        techElement addEventHandler: (BlEventHandler
            on: BlMouseEnterEvent
            do: [ :event |
                techElement border: (BlBorder paint: Color yellow width: 4).
            ]).
        
        techElement addEventHandler: (BlEventHandler
            on: BlMouseLeaveEvent
            do: [ :event |
                techElement border: (BlBorder paint: Color black width: 2).
            ]).
        
        "Click para ver detalles"
        techElement addEventHandler: (BlEventHandler
            on: BlClickEvent
            do: [ :event |
                | info |
                info := 'Technology: ', tech, String cr,
                       'Discussions: ', discussionCount asString, String cr,
                       'Total Mentions: ', mentionCount asString.
                techElement phlow spawnObject: info.
                event consumed: true.
            ]).
        
        container addChild: techElement.
    ].
    
    ^ container asPannableElement
]
