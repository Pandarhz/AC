<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Expédition Écrins - Mode Aventure</title>
    
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;800&family=Orbitron:wght@700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary-color: #000000;
            --accent-color: #ff4500; /* Orange vif type HUD de jeu */
            --text-light: #ffffff;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            width: 100%;
            overflow: hidden;
            font-family: 'Montserrat', sans-serif;
            background-color: #1a1a1a;
        }

        /* --- 1. L'ECRAN D'INTRO (Cinématique) --- */
        #intro-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: #000;
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            /* Animation de disparition de l'écran noir */
            animation: fadeOutScreen 1s ease-out 4s forwards;
            pointer-events: none;
        }

        /* Effet "Letterbox" (Bandes noires cinéma) */
        #intro-screen::before, #intro-screen::after {
            content: '';
            position: absolute;
            left: 0;
            width: 100%;
            height: 10%;
            background: black;
            z-index: 1002;
            border-bottom: 2px solid var(--accent-color);
        }
        #intro-screen::before { top: 0; }
        #intro-screen::after { bottom: 0; border-bottom: none; border-top: 2px solid var(--accent-color); }

        /* Le conteneur du randonneur réaliste */
        .hiker-cinematic {
            position: absolute;
            bottom: 15%; 
            left: -300px; /* Départ hors écran */
            width: 250px;
            height: 350px;
            /* Image réaliste de randonnée détourée (illusion) ou card */
            background-image: url('https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=800&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            box-shadow: 0 0 20px rgba(255, 69, 0, 0.5); /* Lueur orange */
            border-radius: 10px;
            transform: skewX(-10deg); /* Effet de vitesse/dynamique */
            z-index: 1001;
            
            /* L'animation de traversée */
            animation: traverseScreen 3.5s cubic-bezier(0.45, 0, 0.55, 1) forwards;
        }

        /* Texte HUD "Chargement" */
        .hud-text {
            position: absolute;
            bottom: 12%;
            right: 20px;
            font-family: 'Orbitron', sans-serif; /* Police Sci-fi/Jeu */
            color: var(--accent-color);
            font-size: 0.8rem;
            letter-spacing: 2px;
            text-transform: uppercase;
            z-index: 1003;
            animation: blink 1s infinite;
        }

        /* --- 2. LA CARTE ET L'INTERFACE --- */
        #map {
            height: 100%;
            width: 100%;
            position: absolute;
            z-index: 1;
            opacity: 0; /* Caché au début */
            animation: fadeInMap 2s ease-out 3.5s forwards; /* Apparaît après la cinématique */
        }

        .ui-container {
            position: absolute;
            top: 40px;
            left: 0;
            width: 100%;
            text-align: center;
            z-index: 10;
            pointer-events: none;
            opacity: 0;
            animation: fadeInUI 1s ease-out 5s forwards;
        }

        h1 {
            font-family: 'Orbitron', sans-serif;
            font-size: 2.5rem;
            margin: 0;
            color: white;
            text-shadow: 0 0 10px black;
            text-transform: uppercase;
        }

        .coords-display {
            background: rgba(0,0,0,0.7);
            color: var(--accent-color);
            padding: 5px 10px;
            border-radius: 5px;
            font-family: monospace;
            display: inline-block;
            margin-top: 10px;
            font-size: 0.8rem;
        }

        /* Bouton Noir demandé */
        .start-btn {
            position: absolute;
            bottom: 50px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 10;
            background-color: #000000; /* NOIR */
            color: white;
            padding: 18px 40px;
            border-radius: 5px; /* Coins un peu plus carrés style militaire/tech */
            text-decoration: none;
            font-weight: 800;
            font-family: 'Orbitron', sans-serif;
            text-transform: uppercase;
            letter-spacing: 2px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.5);
            border: 1px solid #333;
            pointer-events: auto;
            opacity: 0;
            animation: fadeInUI 1s ease-out 5.5s forwards;
            transition: all 0.3s;
        }

        .start-btn:active {
            transform: translateX(-50%) scale(0.95);
            background-color: #222;
        }

        /* --- KEYFRAMES --- */
        @keyframes traverseScreen {
            0% { left: -300px; opacity: 0; transform: skewX(-10deg) scale(0.8); }
            10% { opacity: 1; }
            80% { opacity: 1; }
            100% { left: 100%; opacity: 0; transform: skewX(-10deg) scale(1); }
        }

        @keyframes fadeOutScreen {
            0% { opacity: 1; pointer-events: auto;}
            100% { opacity: 0; pointer-events: none; visibility: hidden;}
        }

        @keyframes fadeInMap {
            to { opacity: 1; }
        }

        @keyframes fadeInUI {
            to { opacity: 1; }
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>

    <!-- Intro Cinématique -->
    <div id="intro-screen">
        <div class="hiker-cinematic"></div>
        <div class="hud-text">Chargement des données topographiques...</div>
    </div>

    <!-- Interface Finale -->
    <div class="ui-container">
        <h1>Zone Écrins</h1>
        <div class="coords-display">TARGET: 44°57'10.8"N 6°05'50.8"E</div>
    </div>

    <a href="#" class="start-btn" onclick="startExplore()">Lancer l'exploration</a>

    <div id="map"></div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // --- CONFIGURATION ---
        // Coordonnées de départ (Vue d'ensemble)
        const startCoords = [44.90, 6.30]; 
        // Coordonnées Cibles (Lac Besson / Alpe d'Huez)
        // Conversion DMS: 44°57'10.8"N -> 44.9530 | 6°05'50.8"E -> 6.0974
        const targetCoords = [44.9530, 6.0974]; 

        // 1. Init Map
        const map = L.map('map', {
            center: startCoords,
            zoom: 11,
            zoomControl: false,
            attributionControl: false
        });

        // 2. Fond de carte Aventure (OpenTopoMap)
        L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
            maxZoom: 17,
            attribution: 'OpenTopoMap'
        }).addTo(map);

        // 3. Marqueur sur la cible (Optionnel, style aventure)
        const targetIcon = L.divIcon({
            className: 'custom-pin',
            html: '<i class="fas fa-map-marker-alt" style="color:red; font-size:24px;"></i>',
            iconSize: [30, 42],
            iconAnchor: [15, 42]
        });

        // 4. Logique d'animation "FlyTo"
        // On attend que l'intro "Cinématique" soit finie (env 4 secondes)
        setTimeout(() => {
            // Lancement du vol vers les coordonnées cibles
            map.flyTo(targetCoords, 15, {
                animate: true,
                duration: 5 // Vol lent et panoramique de 5 secondes
            });
            
            // Ajouter un marqueur à l'arrivée
            setTimeout(() => {
                L.marker(targetCoords).addTo(map)
                .bindPopup("<b>Point d'arrivée</b><br>44°57'10.8\"N 6°05'50.8\"E").openPopup();
            }, 5000);

        }, 4000); // 4000ms correspond à la fin de l'intro CSS

        // Fonction interaction bouton
        function startExplore() {
            // Nettoyage UI pour immersion totale
            document.querySelector('.ui-container').style.opacity = '0';
            document.querySelector('.start-btn').style.opacity = '0';
            
            // Réactive le zoom
            L.control.zoom({ position: 'bottomright' }).addTo(map);
        }
    </script>
</body>
</html>
