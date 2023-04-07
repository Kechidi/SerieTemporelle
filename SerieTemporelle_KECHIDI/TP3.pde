FloatTable donnees;
float dmin, dmax;
//Les années min et max
int amin, amax;
int[] annees;
float traceX1, traceY1, traceX2, traceY2;
// La colonne de données actuellement utilisée.
int colonne = 0;
// Le nombre de colonnes.
int ncol;
// La police de caractères.
PFont police;
int intervalleAnnees = 10;
int intervalleVolume = 10;
int intervalleVolumeMineur = 5;
int valFun=0;
boolean a1=false;
boolean a2=false;
boolean a3=false;
int lignes;
Integrator[] interp;

int lastColumnChangeTime = 0;
int columnChangeInterval = 500; // intervalle de temps en millisecondes entre les changements de colonne




void setup() {
  size(720, 405);
  //Charger les données de séries temporelles.
  donnees = new FloatTable("lait-the-cafe.tsv");
  ncol = donnees.getColumnCount();        // Le nombre de colonnes.
  dmin = 0;
  dmax = ceil(donnees.getTableMax() / intervalleVolume) * intervalleVolume;
  annees = int(donnees.getRowNames());
  amin = annees[0];
  amax = annees[annees.length - 1];
  //Définir un cadre
  traceX1 = 100;
  traceY1 = 50;
  traceX2 = width - traceX1;
  traceY2 = height - traceY1;

  police = createFont("SansSerif", 20);
  textFont(police);
  lignes = donnees.getRowCount();
  // On charge les valeurs initiales dans les interpolateurs :
  interp = new Integrator[lignes];

  for (int ligne = 0; ligne < lignes; ligne++) {
    interp[ligne] = new Integrator(donnees.getFloat(ligne, 0));
  }

  smooth();

  println(dmax);
}

void draw() {
  /*if(frameCount%50 == 0) {
   //colonne+=1;
   colonne = colonne < 2 ? colonne+1 : 0;
   
   for(int ligne = 0; ligne < lignes; ligne++) {
   interp[ligne].target(donnees.getFloat(ligne,colonne));
   }
   
   }*/
  background(224);

  // Dessine le fond
  fill(255);
  for (int ligne = 0; ligne < lignes; ligne++) {
    interp[ligne].update();
  }
  rectMode(CORNERS);
  noStroke();
  rect(traceX1, traceY1, traceX2, traceY2);

  dessineTitre();
  dessineAxeVolume();
  dessineAxeAnnees();
  if (a1) {
    strokeWeight(1);
    stroke(#5679C1);
    //noFill();
    dessinerHisto(colonne);
  } else if (a2) {
    fill(#211114);
    strokeWeight(2);
    noFill();
    dessineLigneDonnees2(colonne);
    strokeWeight(5);
    stroke(#730b5c);
    dessinePointsDonnees(colonne);
    //mode air
  } else if (a3) {
    fill(#5679C1);
    strokeWeight(5);
    stroke(#5679C1);
    dessineLigneDonneesAir(colonne);
    dessineAxeAnnees();
  } else {
    fill(#211114);
    strokeWeight(2);
    noFill();
    dessineLigneDonnees2(colonne);
    strokeWeight(5);
    stroke(#730b5c);
    dessinePointsDonnees(colonne);
  }
}


void dessineLigneDonneesAir(int col) {
  beginShape();   // On commence la ligne.

  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    if (donnees.isValid(ligne, col)) {
      // float valeur = donnees.getFloat(ligne, col);
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      //point(x, y);
      vertex(x, y);
    }
  }
  vertex(traceX2, traceY2);
  vertex(traceX1, traceY2);
  endShape(CLOSE);  //On términe la ligne
  fill(#000000);
  textSize(20);
  text("Air", width/2, traceY2 -329);
}


void dessineLigneDonnees2(int col) {
  beginShape(); // On commence la ligne.
  stroke(#b3599f);

  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    if (donnees.isValid(ligne, col)) {
      float valeur = interp[ligne].value;
      //float valeur = donnees.getFloat(ligne, col);
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      //point(x, y);
      vertex(x, y);
    }
  }
  endShape(); // On termine la ligne sans fermer la forme.
  textSize(20);
  text("Ligne", width/2, traceY2 -329);
}





void dessinePointsDonnees(int col) {
  strokeWeight(5);
  stroke(#5679C7);
  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    if (donnees.isValid(ligne, col)) {
      float valeur = interp[ligne].value;
      //float valeur = donnees.getFloat(ligne, col);
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      point(x, y);
    }
  }
  textSize(20);
  text("Ligne", width/2, traceY2 -329);
}


void dessineAxeAnnees() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);

  // Des lignes fines en gris clair.
  stroke(224);
  strokeWeight(1);

  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    if (annees[ligne] % intervalleAnnees == 0) {
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      text(annees[ligne], x, traceY2 + 10);
      // Dessine les lignes.
      line(x, traceY1, x, traceY2);
    }
  }
  textSize(12);
  text("Année", width/2, traceY2 + 22);
}
//la focntion keyPressed pour effectuer le changement
void keyPressed() {
  if (key==CODED) {
    //Droite
    if ((keyCode == RIGHT)&& (colonne < ncol-1)) {
      colonne+=1;
      for (int ligne = 0; ligne < lignes; ligne++) {
        interp[ligne].target(donnees.getFloat(ligne, colonne));
      }
    }
    //Gauche
    else if ((keyCode == LEFT)&& (colonne>0)) {
      colonne-=1;
      for (int ligne = 0; ligne < lignes; ligne++) {
        interp[ligne].target(donnees.getFloat(ligne, colonne));
      }
    }
  } else {
    randomFunction();
  }
}
// la fonction mousePressed pour effectuer le changement
void mousePressed() {
  int nouvelleColonne = floor(map(mouseX, 0, width, 0, ncol));
  if (nouvelleColonne != colonne) {
    colonne = nouvelleColonne;
    for (int ligne = 0; ligne < lignes; ligne++) {
      interp[ligne].target(donnees.getFloat(ligne, colonne));
    }
  }
}


//La fonction radom  choisit un mode d'affichage des données aléatoirement (en lignes, histogramme ou aire)
void randomFunction() {
  int r;
  do {
    r=(int)random(1, 4);
  } while (r == valFun);
  a1=false;
  a2=false;
  a3=false;

  switch(r) {
  case 1:
    a1=true;
    valFun=1;
    break;
  case 2:
    a2=true;
    valFun=2;
    break;
  case 3:
    a3=true;
    valFun=3;
    break;
  }
}

void dessineTitre() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text(donnees.getColumnName(colonne), traceX1, traceY1 - 10);
}

void dessineAxeVolume() {
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);

  for (float v = dmin; v <= dmax; v+=intervalleVolumeMineur) {
    if (v % intervalleVolumeMineur == 0) {
      float y = map(v, dmin, dmax, traceY2, traceY1);
      if (v % intervalleVolume == 0) {
        if (v == dmin) {
          textAlign(RIGHT, BOTTOM);
        } else if (v == dmax) {
          textAlign(RIGHT, TOP);
        } else {
          textAlign(RIGHT, CENTER);
        }
        text(floor(v), traceX1 - 10, y);
        line(traceX1 - 4, y, traceX1, y); // Tiret majeur.
      } else {
        line(traceX1 - 2, y, traceX1, y); // Tiret mineur.
      }
    }
  }
  textAlign(CENTER);
  textSize(12);
  text("Litres \n Consommés \n Par Pers.", traceX1-60, height/2);
}

void dessinerHisto(int col) {
  for (int ligne = 0; ligne<lignes; ligne++) {
    if (donnees.isValid(ligne, col)) {
      float values = interp[ligne].value;
      float axeX = map(annees[ligne], amin, amax, traceX1, traceX2);
      float axeY = map(values, dmin, dmax, traceY2, traceY1);
      rectMode(CORNER);
      float taille = traceY2-axeY;
      rect(axeX, axeY, 3, taille);
    }
  }
  textSize(20);
  text("Histogram", width/2, traceY2 -329);
}
