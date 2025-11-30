Class {
	#name : 'CommitGraph',
	#superclass : 'Object',
	#instVars : [
		'commits'
	],
	#category : 'MsrChallenge',
	#package : 'MsrChallenge'
}

{ #category : 'as yet unclassified' }
CommitGraph class >> loadFromDict: dictio [
    | cg |
    cg := self new.
    cg instVarNamed: 'commits' put:
        ((dictio at: 'Sources' ifAbsent: [ #() ])
            collect: [ :each | Commit fromDict: each ]).
    ^ cg
]

{ #category : 'as yet unclassified' }
CommitGraph class >> loadFromFile: aFileRef [
    ^ self loadFromDict: (STONJSON fromString: aFileRef contents)
]

{ #category : 'as yet unclassified' }
CommitGraph >> commits [ ^ commits.
]

{ #category : 'as yet unclassified' }
CommitGraph >> gtViewPrefixRectsOn: aView [
    <gtView>
    ^ aView explicit
        title: 'Prefijos de commits (frecuencia)';
        stencil: [ self visualizePrefixesAsRectanglesInView: aView ].
]

{ #category : 'as yet unclassified' }
CommitGraph >> prefixFrequencies [
    | table |
    table := Dictionary new.
    commits do: [ :c |
        table at: c commitPrefix
            put: ((table at: c commitPrefix ifAbsent: [ 0 ]) + 1)
    ].
    ^ table
]

{ #category : 'as yet unclassified' }
CommitGraph >> visualizePrefixesAsRectanglesInView: aView [
    | mainContainer zoomable scale baseSize maxX currentX currentY 
      maxRowHeight freqs colorPalette colorIndex |

    freqs := self prefixFrequencies.

    "Paleta cualitativa tipo ColorBrewer (cíclica)"
    colorPalette := {
        Color fromHexString: '#a6cee3'.
        Color fromHexString: '#1f78b4'.
        Color fromHexString: '#b2df8a'.
        Color fromHexString: '#33a02c'.
        Color fromHexString: '#fb9a99'.
        Color fromHexString: '#e31a1c'.
        Color fromHexString: '#fdbf6f'.
        Color fromHexString: '#ff7f00'.
        Color fromHexString: '#cab2d6'
    }.
    colorIndex := 1.

    mainContainer := BlElement new
        background: Color white;
        size: 3000 @ 1300;
        clipChildren: false;
        yourself.

    zoomable := BlZoomableElement new
        size: 1600 @ 800;
        clipChildren: false;
        contentElement: mainContainer;
        yourself.

    scale := 2.
    baseSize := 40.
    maxX := 2400.
    currentX := 20.
    currentY := 20.
    maxRowHeight := 0.

    freqs keysAndValuesDo: [ :prefix :count |
        | size square label1 color commitsOfPrefix |

        size := baseSize + (count * scale).
        color := colorPalette at: colorIndex.
        colorIndex := colorIndex \\ colorPalette size + 1.

        commitsOfPrefix := self commits select: [ :c | c commitPrefix = prefix ].

        square := BlElement new
            geometry: BlRectangleGeometry new;
            size: size @ size;
            background: color;
            border: (BlBorder paint: Color black width: 2);
            yourself.

        label1 := BlTextElement new
            text: ((prefix , ' (' , count asString , ')') asRopedText
                fontSize: 14; foreground: Color black; bold);
            yourself.

        square addChild: label1.
        label1 relocate: 6 @ 6.

        "Click → mostrar lista de commits"
        square addEventHandler:
            (BlEventHandler on: BlClickEvent do: [ :evt |

                (aView respondsTo: #setObject:)
                    ifTrue: [
                        "Inspector GT → pone la colección en la vista"
                        aView setObject: commitsOfPrefix
                    ]
                    ifFalse: [
                        "Phlow → abrir ventana nueva con los commits"
                        square phlow spawnObject: commitsOfPrefix
                    ].

                evt consumed: true
            ]).

        "Posicionamiento"
        square relocate: currentX @ currentY.
        maxRowHeight := maxRowHeight max: size.
        currentX := currentX + size + 20.

        (currentX + size > maxX) ifTrue: [
            currentX := 20.
            currentY := currentY + maxRowHeight + 25.
            maxRowHeight := 0
        ].

        mainContainer addChild: square.
    ].

    ^ zoomable asPannableElement

]
