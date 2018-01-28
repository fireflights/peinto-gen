/* @pjs font="./assets/fonts/Oswald-Light.ttf, ./assets/fonts/Oswald-Regular.ttf, ./assets/fonts/Oxygen-Regular.ttf"; */



boolean is_3D = false;

String[] diseases, parts, genes;
float[][] exprs;
float[] cam_pos, cam_up;
int[] alphas;
int box_col;
float min_expr, max_expr, zoom, start_pos_x, start_pos_y, yaw, pitch, box_width, box_height, box_length;
PImage bladder_c, bladder_g, blood_c, blood_g, kidney_c, kidney_g, liver_c, liver_g, lung_c, lung_g, 
    ovary_c, ovary_g, pancreas_c, pancreas_g, prostate_c, prostate_g, stomach_c, stomach_g, 
    thyroid_c, thyroid_g, uterus_c, uterus_g, blood, kidney, liver, lung, ovary, pancreas, prostate, stomach, thyroid, bladder, uterus;
PFont header_font, text_font, text_font_2;
boolean is_bladder, is_blood, is_kidney, is_liver, is_lung, is_ovary, is_pancreas, is_prostate, is_stomach, is_thyroid, is_uterus;

BufferedReader reader;

void setup () {
    size(1200, 800, P3D);
    
    // LOAD FONTS
    header_font = createFont("./assets/fonts/Oswald-Regular.ttf", 20);
    text_font = createFont("./assets/fonts/Oxygen-Regular.ttf", 30);
    text_font_2 = createFont("./assets/fonts/Oswald-Light.ttf", 30);
    
    //header_font = text_font = createFont("FFScala", 32);
    
    // LOAD IMAGES
    bladder_c = loadImage("./assets/img/bladder_c.jpg");
    bladder_g = loadImage("./assets/img/bladder_g.jpg");
    blood_c = loadImage("./assets/img/blood_c.jpg");
    blood_g = loadImage("./assets/img/blood_g.jpg");
    kidney_c = loadImage("./assets/img/kidney_c.jpg");
    kidney_g = loadImage("./assets/img/kidney_g.jpg");
    liver_c = loadImage("./assets/img/liver_c.jpg");
    liver_g = loadImage("./assets/img/liver_g.jpg");
    lung_c = loadImage("./assets/img/lung_c.jpg");
    lung_g = loadImage("./assets/img/lung_g.jpg");
    ovary_c = loadImage("./assets/img/ovary_c.jpg");
    ovary_g = loadImage("./assets/img/ovary_g.jpg");
    pancreas_c = loadImage("./assets/img/pancreas_c.jpg");
    pancreas_g = loadImage("./assets/img/pancreas_g.jpg");
    prostate_c = loadImage("./assets/img/prostate_c.jpg");
    prostate_g = loadImage("./assets/img/prostate_g.jpg");
    stomach_c = loadImage("./assets/img/stomach_c.jpg");
    stomach_g = loadImage("./assets/img/stomach_g.jpg");
    thyroid_c = loadImage("./assets/img/thyroid_c.jpg");
    thyroid_g = loadImage("./assets/img/thyroid_g.jpg");
    uterus_c = loadImage("./assets/img/uterus_c.jpg");
    uterus_g = loadImage("./assets/img/uterus_g.jpg");
    
    //initialization;
     initialize(); 
    //Read file
    String[] lines = loadStrings("./data/FC_FPKM_txt.txt");
    String[] headers = lines[0].split("\t");
    String[] parts_diseases = subset(headers, 1, headers.length - 2);
    parts = new String[parts_diseases.length];
    diseases = new String[parts_diseases.length];
    for(int i = 0; i < parts_diseases.length; i++){
      String[] words = parts_diseases[i].substring(1, parts_diseases[i].length()-1).split(",");
      diseases[i] = words[0];
      parts[i] = words[1];
    }
    
    genes = new String[100];
    for(int i = 1; i < 101; i++) {
      genes[i-1] = lines[i].split("\t")[0];
    }
    
    exprs = new float[lines.length-1][parts_diseases.length];
    max_expr = -100000000;
    min_expr = 100000000;
    for(int i = 0; i < lines.length-1; i++) {
      String[] words = lines[i+1].split("\t");
      String[] string_expr = subset(words, 1, words.length - 2); // -2: remove gene column and variance column
      for(int j = 0; j < string_expr.length; j++){
        float f_expr = float(string_expr[j]); 
        exprs[i][j] = f_expr;
        if(max_expr < f_expr) {
            max_expr = f_expr;
        }
        if(min_expr > f_expr) {
            min_expr = f_expr;
        }
      }
    }

}

void initialize() {
    zoom = 1;
    start_pos_x = start_pos_y = 50;
    cam_pos = new float[3];
    cam_pos[0] = 585;
    cam_pos[1] = 400;
    cam_pos[2] = 1100;
    cam_up = new float[3];
    cam_up[0] = 0;
    cam_up[1] = 1;
    cam_up[2] = 0;
    pitch = 0;
    yaw = 0;
    is_bladder = is_blood = is_kidney = is_liver = is_lung = is_ovary = is_pancreas = is_prostate = is_stomach = is_thyroid = is_uterus = true;
    
}

void draw() {
  background(255);
  apply_filter();
  
  if(is_3D) {
    
    box_width = box_length = (width - 400.0) / exprs[0].length;
    
    //initial location
    float init_x = start_pos_x - box_width;
    float cur_z = -(box_width * genes.length)/2 - box_length - 2150;
    float init_z = cur_z;
    
    stroke(0);
    
    pushMatrix();
    // py equiv: cam_pos_new = [sum(x) for x in zip (cam_pos, cam_dir(pitch, yaw))]
    float[] cam_pos_new = new float[3];
    for(int i = 0; i < 3; i++) {
      float[] temp_cam_dir = cam_dir(pitch, yaw);
      cam_pos_new[0] = cam_pos[0] + temp_cam_dir[0];
      cam_pos_new[1] = cam_pos[1] + temp_cam_dir[1];
      cam_pos_new[2] = cam_pos[2] + temp_cam_dir[2];
    }
    camera(cam_pos[0], cam_pos[1], cam_pos[2], cam_pos_new[0], cam_pos_new[1], cam_pos_new[2], cam_up[0], cam_up[1], cam_up[2]);
    
    //box dimensions subtracted to correct the initial translations below
    translate(init_x, height/2, init_z);
    for(int i = 0; i < genes.length; i++) {
      float cur_x = init_x;
      translate(0, 0, box_length);
      cur_z += box_length;
      pushMatrix();
      for(int j = 0; j < exprs[0].length; j++) {
        translate(box_width, 0, 0);
        float cur_expr, ratio, a, b, c, k;
        if(alphas[j] > 0){
          cur_expr = exprs[i][j];
          if(cur_expr >= 0) { //up-regulated genes
            ratio = cur_expr/max_expr;
            a = (255 - 193) * (1 - ratio) + 193;
            b = (255 - 0) * (1 - ratio) + 0;
            c = (255 - 1) * (1 - ratio) + 1;
            k = -25;
          }
          else {
            ratio = -cur_expr / min_expr; //down-regulated genes
            a = (255 - 112) * (1 + ratio) + 112; //change in opertaion ("1 + ratio") due to the computation "ratio * 500" below (no "if" below)
            b = (255 - 171) * (1 + ratio) + 171;
            c = (255 - 175) * (1 + ratio) + 175;
            k = 25;
          }
          cur_x += box_width;
          pushMatrix();
          box_height = -ratio*500;
          translate(0, box_height/2 + k, 0);
          fill(a, b, c, alphas[j]);
          if (box_height == 0) {
             box_height = 1;
          }
          box(box_width, box_height, box_length);
          popMatrix();
        }
      }
      popMatrix();
    }
    popMatrix();
  }
  else {
    // box_dimensions
    box_width = (width - 400.0) / exprs[0].length;
    box_height = (height - 100.0) / genes.length;
    
    float init_x = start_pos_x - box_width;
    float init_y = start_pos_y - box_height;
    float cur_y = init_y;
    
    pushMatrix();
    scale(zoom);
    noStroke();
    
    init_x = start_pos_x - box_width;
    init_y = cur_y = start_pos_y - box_height;
    
    translate(init_x, init_y, 0);
    
    for(int i = 0; i < genes.length; i++) {
      float cur_x = init_x;
      translate(0, box_height, 0);
      cur_y += box_height;
      pushMatrix();
      
      for(int j = 0; j < exprs[0].length; j++) {
        translate(box_width, 0, 0);
        if(alphas[j] > 0) {
          cur_x += box_width;
          float cur_expr = exprs[i][j];
          float a, b, c, ratio;
          if (cur_expr >= 0) { // up-regulated genes
            ratio = cur_expr / max_expr;
            a = (255 - 193) * (1 - ratio) + 193;
            b = (255 - 0) * (1 - ratio) + 0;
            c = (255 - 1) * (1 - ratio) + 1;
          }
          else {
            ratio = cur_expr / min_expr; // down-regulated genes
            a = (255 - 112) * (1 - ratio) + 112;
            b = (255 - 171) * (1 - ratio) + 171;
            c = (255 - 175) * (1 - ratio) + 175;
          }
          fill(a, b, c, alphas[j]);
          rect(0, 0, box_width, box_height);
          
        }
      }
      popMatrix();
    }
    popMatrix();
    //hint(DISABLE_DEPTH_TEST);
    display_gene_2D(mouseX, mouseY);
    //hint(ENABLE_DEPTH_TEST);
  }
  
  hint(DISABLE_DEPTH_TEST);

  
  // Options
  pushMatrix();
  translate(900, 0, 0);
  stroke(0);
  fill(0);
  rect(0, 0, 1, height);
  fill(255);
  rect(0, 0, width - 900, height); //box to cover heat map beyond border
  translate(20, 60, 1);
    
  noFill();
  if(is_3D){
      rect(0, 0, 20, 20);
      fill(0);
      rect(0, 30, 20, 20);
  }
  else {
      rect(0, 30, 20, 20);
      fill(0);
      rect(0, 0, 20, 20);
  }
  
  ////mode text
  fill(0);
  textFont(header_font);
  textSize(20);
  text("Mode", 10, -20, 10);
  textFont(text_font);
  textSize(18);
  text("2D", 30, 19, 30);
  text("3D", 30, 49, 30);
  
  //text(mouseX, 60, 10, 30);
  //text(mouseY, 60, 50, 30);
  
  noFill();
  translate(188, -34, 0);
  rect(0, -2, 70, 32);
  
  textFont(header_font);
  textSize(15);
  text("Reset", 0, 25, 30);
  popMatrix();
  
  pushMatrix();
  noFill();
  translate(950, 725, 0);
  rect(-2, 0, 70, 32);
  rect(121, 0, 70, 32);
  //#reset text
  textFont(header_font);
  textSize(28);
  text("All", 18, 8, 30);
  text("None", 125, 8, 30);
  popMatrix();
      fill(255);
  noStroke();
  
  pushMatrix();
  translate(935, 125, 0);
  image(blood, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(liver, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(ovary, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(prostate, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(thyroid, 0, 0, 100, 100);
  translate(60, 100, 0);
  image(uterus, 0, 0, 100, 100);
  popMatrix();
  
  pushMatrix();
  translate(1055, 125, 0);
  image(kidney, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(lung, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(pancreas, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(stomach, 0, 0, 100, 100);
  translate(0, 100, 0);
  image(bladder, 0, 0, 100, 100);
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}

//void mouseScrolled(MouseEvent event) {
//  if (is_3D) {
//    float[] front_vec = cam_dir(pitch, yaw);
//    front_vec[0] *= mouseScroll * 10;
//    front_vec[1] *= mouseScroll * 10;
//    front_vec[2] *= mouseScroll * 10;
//    for(int i = 0; i < 3; i++) {
//      cam_pos[i] += front_vec[i];
//    }
//  }
//  else {
//    float cur_zoom = zoom;
//    zoom += mouseScroll * 0.02;
//    start_pos_x -= ((mouseX/cur_zoom * zoom) - mouseX) / zoom;
//  }
//}

void mouseWheel(MouseEvent event) {
  if(is_3D) {
    float[] front_vec = cam_dir(pitch, yaw);
    front_vec[0] *= event.getCount() * 10;
    front_vec[1] *= event.getCount() * 10;
    front_vec[2] *= event.getCount() * 10;
    for(int i = 0; i < 3; i++) {
      cam_pos[i] += front_vec[i];
    }
  }
}

void mouseDragged() {
  if (is_3D) {
    if (mouseButton == LEFT) {
      float[] cam_dir_value = cam_dir(pitch, yaw);
      //float[] right_vec = {right_pvec.x * delta, right_pvec.y * delta, right_pvec.z * delta};
      float[] temp = cross_product(cam_dir_value, cam_up);
      
      float right_multiplier = (mouseX - pmouseX)*2;
      float[] right_vec = {temp[0]*right_multiplier, temp[1]*right_multiplier, temp[2]*right_multiplier};
      
      float up_multiplier = (mouseY - pmouseY)*2;
      float[] up_vec = {cam_up[0]*up_multiplier, cam_up[1]*up_multiplier, cam_up[2]*up_multiplier};
      
      for(int i = 0; i < 3; i++) {
       cam_pos[i] += right_vec[i]; 
       cam_pos[i] += up_vec[i];
      }
    }
    if (mouseButton == RIGHT) {
      yaw += (mouseX - pmouseX) * 0.02;
      pitch += (mouseY - pmouseY) * 0.02;
    }
  }
  else {
    if (mouseButton == LEFT) {
      start_pos_x += (mouseX - pmouseX) * 2;
      start_pos_y += (mouseY - pmouseY) * 2;
    }
  }
}

void mousePressed() {
  if (mouseX > 920 && mouseX < 940) {
    if(mouseY > 60 && mouseY < 80) {
      is_3D = false; 
     }
    if(mouseY > 90 && mouseY < 110) {
      is_3D = true; 
    }
  }
 
  if(mouseX > 1120 && mouseX < 1190) {
   
    if(mouseY > 25 && mouseY < 57) {
   
      initialize(); 
    }
  }
  if(mouseX > 935 && mouseX < 1035) {
    if(mouseY > 125 && mouseY < 225) {
      is_blood = !is_blood;
    }
    if(mouseY > 225 && mouseY < 325) {
      is_liver = !is_liver;
    }
    if(mouseY > 325 && mouseY < 425) {
      is_ovary = !is_ovary;
    }
    if(mouseY > 425 && mouseY < 525) {
      is_prostate = !is_prostate;
    }
    if(mouseY > 525 && mouseY < 625) {
      is_thyroid = !is_thyroid;
    }
  }
  if(mouseX > 985 && mouseX < 1085) {
    if(mouseY > 625 && mouseY < 725) {
      is_uterus = !is_uterus;
    }
  }
  if(mouseX > 1055 && mouseX < 1155) {
    if(mouseY > 125 && mouseY < 225) {
      is_kidney = !is_kidney;
    }
    if(mouseY > 225 && mouseY < 325) {
      is_lung = !is_lung;
    }
    if(mouseY > 325 && mouseY < 425) {
      is_pancreas = !is_pancreas;
    }
    if(mouseY > 425 && mouseY < 525) {
      is_stomach = !is_stomach;
    }
    if(mouseY > 525 && mouseY < 625) {
      is_bladder = !is_bladder;
    }
  }
  
  if(mouseY > 725 && mouseY < 757) {  
    if(mouseX > 948 && mouseX < 1020) {
      is_bladder = is_blood = is_kidney = is_liver = is_lung = is_ovary = is_pancreas = is_prostate = is_stomach = is_thyroid = is_uterus = true;
    }
    if(mouseX > 1071 && mouseX < 1141) {
      is_bladder = is_blood = is_kidney = is_liver = is_lung = is_ovary = is_pancreas = is_prostate = is_stomach = is_thyroid = is_uterus = false;
    }
  }
}

float[] cross_product(float[] vec_x, float[] vec_y) {
   float[] ret = {vec_x[1] * vec_y[2] - vec_x[2] * vec_y[1], -(vec_x[0] * vec_y[2] - vec_x[2] * vec_y[0]),
        vec_x[0] * vec_y[1] - vec_x[1] * vec_y[0]};
    return ret;
  }

boolean is_gene_2D(float x, float y) {
    float ul_cor_x = start_pos_x * zoom;
    float ul_cor_y = start_pos_y * zoom;
    float lr_cor_x = (start_pos_x + width - 400) * zoom;
    float lr_cor_y = (start_pos_y + height - 100) * zoom;
    
    if(x > max(0, ul_cor_x) && x < min(900, lr_cor_x)) {
        if(y > ul_cor_y && y < lr_cor_y) {
            return true;
        }
        else {
            return false;
        }
    }
    else {
        return false;
    }
}
void display_gene_2D(float x, float y) {
  if (is_gene_2D(x, y)) {
    box_col = int((mouseX - start_pos_x * zoom)/(box_width * zoom));
    if (alphas[box_col] > 0) {
      int box_row = int((mouseY - start_pos_y * zoom)/(box_height * zoom));
      int box_num = box_row * exprs[0].length + box_col;
      
      String disease = diseases[box_col];
      String part = parts[box_col];
      String gene_id = genes[box_row].split("/")[0];
      String gene_name = genes[box_row].split("/")[1];
      float fc = exprs[box_row][box_col];
     
      stroke(0);
      fill(255, 200);
      pushMatrix();
      translate(mouseX, mouseY, 5);
      int rect_x, rect_y;
      rect_x = 0;
      rect_y = 0;
      if(mouseX > 625) {
          rect_x = -275;
      }
      if(mouseY < 61) {
          rect_y = 61;
      }
      
      
      rect(rect_x, rect_y, 275, 102);
      fill(0);
      textFont(header_font);
      textSize(16);
      text("Part: ", rect_x + 10, rect_y + 10, 10);
      text("Disease: ", rect_x + 10, rect_y + 10 + 20,10);
      text("Gene ID: ", rect_x + 10, rect_y + 10 + 20 + 20, 10);
      text("Gene Name: ", rect_x + 10, rect_y + 30 + 20 + 20, 10);
      text("Fold Change: ", rect_x + 10, rect_y + 50 + 20 + 20, 10);
      textFont(text_font_2);
      textSize(16);
      text(part, rect_x + 90, rect_y + 10, 10);
      text(disease, rect_x + 90, rect_y + 10 + 20, 10);
      text(gene_id, rect_x + 90, rect_y + 10 + 20 + 20, 10);
      text(gene_name, rect_x + 90, rect_y + 30 + 20 + 20, 10);
      text(fc, rect_x + 90, rect_y + 50 + 20 + 20, 10);
      popMatrix();
    }
  } 
}

float[] cam_dir(float p, float y) {
    float[] ret = new float[3];
    ret[0] = cos(p) * sin(y);
    ret[1] = sin(p);
    ret[2] = -cos(p) * cos(y);
    return ret;
}
void apply_filter() {
    alphas = new int[16];
    
    blood = blood_g;
    kidney = kidney_g;
    liver = liver_g;
    lung = lung_g;
    ovary = ovary_g;
    pancreas = pancreas_g;
    prostate = prostate_g;
    stomach = stomach_g;
    thyroid = thyroid_g;
    bladder = bladder_g;
    uterus = uterus_g;
    
    if(is_blood) {
        blood = blood_c;
        alphas[0] = alphas[1] = alphas[2] = 255;
    }
    if(is_kidney) {
        kidney = kidney_c;
        alphas[3] = alphas[4] = 255;
    }
    if(is_liver) {
        liver = liver_c;
        alphas[5] = alphas[6] = 255;
    }
    if(is_lung) {
        lung = lung_c;
        alphas[7] = alphas[8] = 255;
    }
    if(is_ovary) {
        ovary = ovary_c;
        alphas[9] = 255;
    }
    if(is_pancreas) {
        pancreas = pancreas_c;
        alphas[10] = 255;
    }
    if(is_prostate) {
        prostate = prostate_c;
        alphas[11] = 255;
    }
    if (is_stomach) {
        stomach = stomach_c;
        alphas[12] = 255;
    }
    if(is_thyroid) {
        thyroid = thyroid_c;
        alphas[13] = 255;
    }
    if(is_bladder){
        bladder = bladder_c;
        alphas[14] = 255;
    }
    if(is_uterus){
        uterus = uterus_c;
        alphas[15] = 255;
    }
    
    blood.resize(100, 100);
    kidney.resize(100, 100);
    liver.resize(100, 100);
    lung.resize(100, 100);
    ovary.resize(100, 100);
    pancreas.resize(100, 100);
    prostate.resize(100, 100);
    stomach.resize(100, 100);
    thyroid.resize(100, 100);
    bladder.resize(100, 100);
    uterus.resize(100, 100);
}