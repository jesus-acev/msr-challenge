Class {
	#name : #CommitGraph,
	#superclass : #Object,
	#instVars : [
		'commits',
		'fileName'
	],
	#category : #'MsrChallenge-Model'
}

{ #category : #'as yet unclassified' }
CommitGraph class >> fromFile: aFileName [
    "Crea una instancia de CommitGraph desde un archivo JSON"
    ^ self new from: aFileName
]

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

{ #category : #'as yet unclassified' }
CommitGraph >> from: aFileName [
    "Lee el archivo JSON y carga los commits - VERSIÓN CON DEBUG"
    | fileContent jsonData sources |
    
    "Guarda el nombre del archivo"
    fileName := aFileName.
    
    "Lee el contenido del archivo"
    fileContent := aFileName asFileReference contents.
    
    "Debug: mostrar si se leyó el archivo"
    Transcript show: 'File loaded, size: ', fileContent size asString; cr.
    
    "Parsea el JSON usando STON"
    jsonData := STONJSON fromString: fileContent.
    
    "Debug: mostrar estructura"
    Transcript show: 'JSON parsed, keys: ', jsonData keys asString; cr.
    
    "Extrae el array de Sources"
    sources := jsonData at: 'Sources' ifAbsent: [ 
        Transcript show: 'WARNING: No Sources found!'; cr.
        #() 
    ].
    
    "Debug: mostrar cantidad"
    Transcript show: 'Sources found: ', sources size asString; cr.
    
    "Guarda los commits - IMPORTANTE: asegurar que NO sea nil"
    commits := sources asOrderedCollection.
    
    "Debug: verificar que commits no sea nil"
    Transcript show: 'Commits initialized: ', commits size asString; cr.
    
    "Retorna self para inspección"
    ^ self
]

{ #category : #'as yet unclassified' }
CommitGraph >> gtPrefixVisualizationFor: aView [
    <gtView>
    ^ aView explicit
        title: 'Prefix Visualization';
        priority: 1;
        stencil: [ self visualizePrefixes ]
]

{ #category : #'as yet unclassified' }
CommitGraph >> initialize [
    super initialize.
    commits := OrderedCollection new.
    fileName := ''
]

{ #category : #'as yet unclassified' }
CommitGraph >> prefixMentions [
    "Analiza la frecuencia de prefijos de commit en conversaciones"
    | prefixes results |
    
    "VERIFICAR que commits no sea nil"
    commits ifNil: [ 
        Transcript show: 'ERROR: commits is nil!'; cr.
        ^ Dictionary new 
    ].
    
    "Define los prefijos a buscar"
    prefixes := #('fix' 'add' 'docs' 'bug' 'feat' 'update' 'remove' 'refactor').
    
    "Inicializa el diccionario de resultados"
    results := Dictionary new.
    prefixes do: [ :prefix | results at: prefix put: 0 ].
    
    "Debug"
    Transcript show: 'Analyzing ', commits size asString, ' commits'; cr.
    
    "Procesa cada commit"
    commits do: [ :commit |
        | conversationText |
        conversationText := self extractConversationTextFrom: commit.
        
        "Cuenta menciones de cada prefijo"
        prefixes do: [ :prefix |
            | mentions |
            mentions := self countMentionsOf: prefix in: conversationText.
            results at: prefix put: (results at: prefix) + mentions.
        ].
    ].
    
    Transcript show: 'Analysis complete'; cr.
    ^ results
]

{ #category : #'as yet unclassified' }
CommitGraph >> visualizePrefixes [
    "Visualiza prefijos como cuadrados, tamaño según frecuencia"
    | container colors prefixData maxMentions |
    
    container := BlElement new
        layout: BlFlowLayout horizontal;
        constraintsDo: [ :c |
            c horizontal fitContent.
            c vertical fitContent ];
        padding: (BlInsets all: 20);
        background: Color white;
        yourself.
    
    "Colores para cada prefijo"
    colors := Dictionary new
        at: 'fix' put: (Color r: 0.9 g: 0.2 b: 0.2);        "Rojo"
        at: 'add' put: (Color r: 0.2 g: 0.8 b: 0.2);        "Verde"
        at: 'docs' put: (Color r: 0.2 g: 0.5 b: 0.9);       "Azul"
        at: 'bug' put: (Color r: 0.9 g: 0.5 b: 0.1);        "Naranja"
        at: 'feat' put: (Color r: 0.6 g: 0.2 b: 0.9);       "Púrpura"
        at: 'update' put: (Color r: 0.2 g: 0.7 b: 0.8);     "Cyan"
        at: 'remove' put: (Color r: 0.8 g: 0.3 b: 0.3);     "Rojo claro"
        at: 'refactor' put: (Color r: 0.5 g: 0.5 b: 0.5);   "Gris"
        yourself.
    
    "Obtener datos de prefijos - ASEGURAR QUE SEA UN DICTIONARY"
    prefixData := self prefixMentions.
    
    "Debug"
    Transcript show: 'prefixData class: ', prefixData class asString; cr.
    Transcript show: 'prefixData: ', prefixData asString; cr.
    
    "Encontrar el máximo para escalar - CORREGIDO"
    maxMentions := 1.
    prefixData valuesDo: [ :count | 
        count > maxMentions ifTrue: [ maxMentions := count ].
    ].
    
    Transcript show: 'maxMentions: ', maxMentions asString; cr.
    
    "Crear un cuadrado para cada prefijo"
    #('fix' 'add' 'docs' 'bug' 'feat' 'update' 'remove' 'refactor') do: [ :prefix |
        | mentions size squareElement label countLabel |
        
        "Obtener menciones - CORREGIDO"
        mentions := prefixData at: prefix ifAbsent: [ 0 ].
        
        Transcript show: prefix, ': ', mentions asString; cr.
        
        "Tamaño del cuadrado basado en menciones (mínimo 50, máximo 200)"
        size := mentions = 0 
            ifTrue: [ 50 ]
            ifFalse: [ ((mentions / maxMentions * 150) + 50) asInteger ].
        
        "Crear cuadrado"
        squareElement := BlElement new
            geometry: BlRectangleGeometry new;
            size: size @ size;
            background: (colors at: prefix);
            border: (BlBorder paint: Color black width: 2);
            margin: (BlInsets all: 15);
            yourself.
        
        "Label con nombre del prefijo"
        label := BlTextElement new
            text: (prefix asRopedText 
                fontSize: 16; 
                foreground: Color white;
                bold);
            yourself.
        
        squareElement addChild: label.
        label relocate: 10 @ 10.
        
        "Contador de menciones"
        countLabel := BlTextElement new
            text: (mentions asString asRopedText 
                fontSize: 24; 
                foreground: Color white;
                bold);
            yourself.
        
        squareElement addChild: countLabel.
        countLabel relocate: 10 @ (size - 35).
        
        "Interactividad - hover"
        squareElement addEventHandler: (BlEventHandler
            on: BlMouseEnterEvent
            do: [ :event |
                squareElement border: (BlBorder paint: Color yellow width: 4).
            ]).
        
        squareElement addEventHandler: (BlEventHandler
            on: BlMouseLeaveEvent
            do: [ :event |
                squareElement border: (BlBorder paint: Color black width: 2).
            ]).
        
        "Click para detalles"
        squareElement addEventHandler: (BlEventHandler
            on: BlClickEvent
            do: [ :event |
                | info percentage |
                percentage := maxMentions > 0 
                    ifTrue: [ ((mentions / maxMentions * 100) printShowingDecimalPlaces: 1), '%' ]
                    ifFalse: [ '0%' ].
                
                info := Dictionary new
                    at: 'Prefix' put: prefix;
                    at: 'Mentions' put: mentions;
                    at: 'Size' put: size;
                    at: 'Percentage' put: percentage;
                    yourself.
                squareElement phlow spawnObject: info.
                event consumed: true.
            ]).
        
        container addChild: squareElement.
    ].
    
    ^ container
]
