/* @pjs font="./assets/fonts/Oswald-Light.ttf, ./assets/fonts/Oswald-Regular.ttf, ./assets/fonts/Oxygen-Regular.ttf"; */

float zoom, start_pos_x, start_pos_y, diameter, radius;
int n_complexity_levels, complexity, box_height;
int[] complexities;
PFont header_font, text_font, text_font_2;
float[][] centers, genes_g, genes_h;
Intensity[] intensities;
Node[] nodes;
int start_millis;

void setup(){
    size(1200, 800, P2D);
    
    // LOAD FONTS
    header_font = createFont("./assets/fonts/Oswald-Regular.ttf", 48);
    text_font = createFont("./assets/fonts/Oxygen-Regular.ttf", 48);
    text_font_2 = createFont("./assets/fonts/Oswald-Light.ttf", 48);
    
    zoom = 1;
    start_pos_x = start_pos_y = 0;
    
    diameter = 80;
    radius = diameter/2;

    String[] genes = load_string_array_from_file("./data/mcf_final_gene_list.csv");
    float[] genes_a = load_float_array_from_file("./data/mcf_alpha.csv");
    float[] genes_b = load_float_array_from_file("./data/mcf_beta.csv");
    genes_g = load_arrays_from_file("./data/mcf_g.csv");
    genes_h = load_arrays_from_file("./data/mcf_h.csv");
    
    for(int i = 0; i < genes.length; i++) {
      genes[i] = genes[i].substring(1, genes[i].length - 1);
    }

    int n_genes = genes_a.length;
    // centers = new float[n_genes][2];
    // float[] main_circ_center = {(width - 100 - diameter)/2, height/2};
    // float main_circ_radius = (height - 100 - diameter)/2;
    // int zero_counter = 0;
    // for(int i = 0; i < n_genes; i++) {
    //   centers[i][0] = main_circ_center[0] + main_circ_radius*cos(2*PI/n_genes*i); 
    //   centers[i][1] = main_circ_center[1] + main_circ_radius*sin(2*PI/n_genes*i);  

    //   genes_g[i][i] = 0;
    //   genes_h[i][i] = 0;

    //   if(sum_abs(genes_g[i]) == 0) {
    //    genes_a[i] = 0;
    //    zero_counter += 1;
    //   }
    //   if(sum_abs(genes_h[i]) == 0) {
    //    genes_b[i] = 0;
    //    zero_counter += 1;
    //   }
    // }
    
    intensities = new Intensity[n_genes*2];
    for(int i = 0; i < n_genes; i++) {
     Intensity intensity = new Intensity(i, "g", genes_a[i]);
     intensities[i] = intensity;
    }
    for(int i = n_genes; i < n_genes*2; i++) {
     Intensity intensity = new Intensity(i-n_genes, "h", genes_b[i-n_genes]);
     intensities[i] = intensity; 
    }

    intensities = bubble_sort_and_trim_intensities(intensities, 2 * n_genes);

    // n_complexity_levels = genes_a.length + genes_b.length - zero_counter;
    // intensities = bubble_sort_and_trim_intensities(intensities, n_complexity_levels);

    // This part takes out two-way connections. This is to make sure that the network is sparse and that complex feedback mechanisms are not considered.
    // (These may be important, but for the website's purpose and the visualization's current state, it is intractable.)
    for(int i = 0; i < intensities.length; i++) {
      Intensity intensity = intensities[i];
      int intensity_num = intensity.i;
      if(intensity.type == "g") {
        for(int j = 0; j < n_genes; j++) {
          if(genes_g[intensity_num][j] != 0) {
            genes_g[j][intensity_num] = 0;
            genes_h[j][intensity_num] = 0;
          }
        }
      }
      else {
        for(int j = 0; j < n_genes; j++) {
          if(genes_h[intensity_num][j] != 0) {
            genes_g[j][intensity_num] = 0;
            genes_h[j][intensity_num] = 0;
          }
        }
      }
    }

    centers = new float[n_genes][2];
    float[] main_circ_center = {(width - 100 - diameter)/2, height/2};
    float main_circ_radius = (height - 100 - diameter)/2;
    int zero_counter = 0;
    for(int i = 0; i < n_genes; i++) {
      centers[i][0] = main_circ_center[0] + main_circ_radius*cos(2*PI/n_genes*i); 
      centers[i][1] = main_circ_center[1] + main_circ_radius*sin(2*PI/n_genes*i);  

      genes_g[i][i] = 0;
      genes_h[i][i] = 0;

      if(sum_abs(genes_g[i]) == 0) {
       genes_a[i] = 0;
       zero_counter += 1;
      }
      if(sum_abs(genes_h[i]) == 0) {
       genes_b[i] = 0;
       zero_counter += 1;
      }
    }

    n_complexity_levels = genes_a.length + genes_b.length - zero_counter;
    
    for(int i = 0; i < n_genes; i++) {
     Intensity intensity = new Intensity(i, "g", genes_a[i]);
     intensities[i] = intensity;
    }
    for(int i = n_genes; i < n_genes*2; i++) {
     Intensity intensity = new Intensity(i-n_genes, "h", genes_b[i-n_genes]);
     intensities[i] = intensity; 
    }
    intensities = bubble_sort_and_trim_intensities(intensities, n_complexity_levels);
    
    nodes = new Node[n_genes];
    for(int i = 0; i < n_genes; i++) {
     nodes[i] = (new Node(genes[i], n_genes, genes_a[i], genes_b[i], genes_g[i], genes_h[i], centers[i])); 
    }
    
    complexities = new int[n_complexity_levels + 1];
    complexities[0] = 1;
    complexity = 0;
    start_millis = millis();
}

void draw() {
  
  background(255);

  for(int i = 0; i < nodes.length; i++) {
    nodes[i].state = "inactive";
  }
  
  pushMatrix();
  scale(zoom);
  
  for(int i = 0; i < complexity - 1; i++) {
    stroke(0);
    Intensity intensity = intensities[i];
    
    for(int j = 0; j < nodes.length; j++) {
      Node node = nodes[j];
      if(node.state == "active") {
        node.state = "done";
      }
    }

    Node cur_node = nodes[intensity.i];
    
    int[] cur_incoming_nodes;
    if(intensity.type == "g") {
      cur_incoming_nodes = cur_node.incoming_g();
    }
    else {
      cur_incoming_nodes = cur_node.incoming_h();
    }

    for(int j = 0; j < cur_incoming_nodes.length; j++) {
      int node_num = cur_incoming_nodes[j];
      if(node_num != 0) {
        nodes[node_num].state = "done";
      }
    }

    cur_node.state = "done";
    strokeWeight(3);
    if(intensity.type == "g") {
      stroke(112, 171, 175); 
    }
    else {
      stroke(193, 0, 1);
    }
    cur_node.draw_edges(radius, nodes, cur_incoming_nodes, false, intensity.type);
  }

  for(int j = 0; j < nodes.length; j++) {
    nodes[j].draw_node(diameter);
  }

  if(complexity>0) {
    Intensity intensity = intensities[i];
    
    for(int j = 0; j < nodes.length; j++) {
      Node node = nodes[j];
      if(node.state == "active") {
        node.state = "done";
      }
    }

    Node cur_node = nodes[intensity.i];
    int[] cur_incoming_nodes;
    if(intensity.type == "g") {
      cur_incoming_nodes = cur_node.incoming_g();
    }
    else {
      cur_incoming_nodes = cur_node.incoming_h();
    }
    for(int j = 0; j < cur_incoming_nodes.length; j++) {
      int node_num = cur_incoming_nodes[j];
      if(node_num != 0) {
        nodes[node_num].state = "done";
      }
    }

    cur_node.state = "active";

    if(millis() - start_millis > 500) {
      cur_node.draw_node(diameter);
    }

    if(millis() - start_millis > 1000) {
      for(int j = 0; j < nodes.length; j++) {
        if(j != intensity.i) {
          nodes[j].draw_node(diameter);
        }
      }
    }
    
    if(millis() - start_millis > 1500) {
      strokeWeight(3);
      if(intensity.type == "g") {
        stroke(112, 171, 175); 
      }
      else {
        stroke(193, 0, 1);
      }
      cur_node.draw_edges(radius, nodes, cur_incoming_nodes, true, intensity.type);
    }
    
  }

  // Node cur_node = nodes[intensity.i];
  


  popMatrix();
  
  
  // UI
  
  pushMatrix();
  translate(1075, 70);
  box_height = 510/(n_complexity_levels+1);
  strokeWeight(3);
  
  for(int i = 0; i <= n_complexity_levels; i++) {
    stroke(0);
    translate(0, box_height);
    if(complexities[n_complexity_levels - i] == 0) {
      fill(193 + (255 - 193) * i / (n_complexity_levels + 1), 255 * i / (n_complexity_levels + 1), 1 + (255 - 1) * i / (n_complexity_levels + 1));
    }
    else {
      fill(42, 81, 93);
    }
    rect(0, 0, 30, box_height);
  }
  
  // Network Complexity
  translate(-65, 75);
  fill(0);
  textFont(header_font);
  textSize(28);
  text("Network", 0, 0);
  translate(0, 30);
  text("Complexity", 0, 0);
  noFill();
  translate(121, -49);
  rect(0, 0, 50, 50);
  fill(0);
  text(complexity, 26 - textWidth(complexity)/2, 36);
  
  if (complexity != 0) {
    textFont(text_font);
    textSize(25);
    translate(-1075, 79);
    stroke(112, 171, 175);
    line(0, 0, 40, 0);
    translate(45, 10);
    text("Activation", 0, 0);
    translate(-45, 20);
    stroke(193, 0, 1);
    line(0, 0, 40, 0);
    translate(45, 10);
    text("Inhibition", 0, 0);
  }
  popMatrix();
  
  display_node(mouseX, mouseY);
  
}

Intensity[] bubble_sort_and_trim_intensities(Intensity[] arr, int n_complexity_levels) {
  for(int i = arr.length-1; i > 0; i--) {
    for(int j = 0; j < i; j++) {
      float curr = arr[j].value;
      float next = arr[j+1].value;
      if(curr < next) {
        Intensity temp = arr[j+1];
        arr[j+1] = arr[j];
        arr[j] = temp;
      }
    }
  }
 
 
  Intensity[] ret = new Intensity[n_complexity_levels];
  for(int i = 0; i < n_complexity_levels; i++) {
    ret[i] = arr[i]; 
  }
  return ret;
}

float sum_abs(float[] array) {
  float ret = 0;
  for(int i = 0; i < array.length; i++) {
   ret += abs(array[i]);
  }
  return ret;
  
}

float[] load_float_array_from_file(String filename) {
  String[] lines = loadStrings(filename);
  float[] ret = new float[lines.length - 1];
  for(int i = 1; i < lines.length; i++) {
    String[] values = lines[i].split(",");
    ret[i-1] = float(values[1]);
  }
  return ret;
}

String[] load_string_array_from_file(String filename) {
  String[] lines = loadStrings(filename);
  String[] ret = new String[lines.length - 1];
  for(int i = 1; i < lines.length; i++) {
    String[] values = lines[i].split(",");
    ret[i-1] = values[1];
  }
  return ret;
}


float[][] load_arrays_from_file(String filename) {
  String[] lines = loadStrings(filename);
  String[] headers = lines[0].split(",");
  float[][] ret = new float[lines.length - 1][headers.length-1];
  
  for(int i = 1; i < lines.length; i++) {
    String[] values = lines[i].split(",");
    for(int j = 1; j < values.length; j++) {
     ret[i-1][j-1] = float(values[j]);
    }
  }
  return ret;
}

void mouseScrolled(MouseEvent event) {
  float cur_zoom = zoom;
  zoom += mouseScroll * 0.002;
  start_pos_x -= ((mouseX /cur_zoom * zoom) - mouseX) / zoom;
  start_pos_y -= ((mouseY / cur_zoom * zoom) - mouseY) / zoom;
}

void mouseDragged() {
  if(mouseButton == LEFT) {
    start_pos_x += (mouseX - pmouseX) * 2;
    start_pos_y += (mouseY - pmouseY) * 2;
  }
}

void mousePressed() {
  if(1075 <= mouseX && mouseX <= 1105 && 70 + box_height <= mouseY && mouseY <= 580 + box_height) {
    complexities = new int[n_complexity_levels + 1];
    complexities[int((580 + box_height - mouseY) / box_height)] = 1;
    complexity = int((580 + box_height - mouseY) / box_height);
    start_millis = millis();
  }
}


void draw_arrow(float radius, float[] center_circ1, float[] center_circ2, boolean grow_line, String type) { 
  float x1 = center_circ1[0];
  float y1 = center_circ1[1];
  float x2 = center_circ2[0];
  float y2 = center_circ2[1];
  float dist_bet_circs = dist(x1, y1, x2, y2);
  
  float new_x1, new_x2, new_y1, new_y2;
  if(x1 < x2) {
    new_x1 = x1 + radius / dist_bet_circs * (x2 - x1) * 1.2;
    new_x2 = x2 - radius / dist_bet_circs * (x2 - x1) * 1.2;
  }
  else {
    new_x1 = x1 - radius / dist_bet_circs * (x1 - x2) * 1.2;
    new_x2 = x2 + radius / dist_bet_circs * (x1 - x2) * 1.2;
  }
  if(y1 > y2) {
    new_y1 = y1 + radius / dist_bet_circs * (y2 - y1) * 1.2;
    new_y2 = y2 - radius / dist_bet_circs * (y2 - y1) * 1.2;
  }
  else {
    new_y1 = y1 - radius / dist_bet_circs * (y1 - y2) * 1.2;
    new_y2 = y2 + radius / dist_bet_circs * (y1 - y2) * 1.2;
  }
  
  if(grow_line){
    int grow_time = 1000; 
    interpolate = (float)(millis()-start_millis-1500)/grow_time;
    if(interpolate < 1) {
      line(new_x1, new_y1, (int)( (1-interpolate)*new_x1 + interpolate*new_x2),
        (int)( (1-interpolate)*new_y1 + interpolate*new_y2 ) );
    }
    else {
      line(new_x1, new_y1, new_x2, new_y2)
      pushMatrix();
      translate(new_x2, new_y2);
      float theta = acos((new_x1 - new_x2)/dist(new_x1, new_y1, new_x2, new_y2));
      if(type == "g") {
        if(new_y2 > new_y1) {
          rotate(-theta - PI / 4);
          line(0, 0, 10, 0);
          rotate(PI / 2);
          line(0, 0, 10, 0);
        }
        else {
          rotate(theta + PI / 4);
          line(0, 0, 10, 0);
          rotate(-PI / 2);
          line(0, 0, 10, 0);
        }
      }
      else {
        if(new_y2 > new_y1) {
          rotate(-theta - PI / 2);
          line(-10, 0, 10, 0);
        }
        else {
          rotate(theta + PI / 2);
          line(-10, 0, 10, 0);
        }
      }
      popMatrix();
    }
  }
  else {
      line(new_x1, new_y1, new_x2, new_y2 )
      pushMatrix();
      translate(new_x2, new_y2);
      float theta = acos((new_x1 - new_x2)/dist(new_x1, new_y1, new_x2, new_y2));
      if(type == "g") {
        if(new_y2 > new_y1) {
          rotate(-theta - PI / 4);
          line(0, 0, 10, 0);
          rotate(PI / 2);
          line(0, 0, 10, 0);
        }
        else {
          rotate(theta + PI / 4);
          line(0, 0, 10, 0);
          rotate(-PI / 2);
          line(0, 0, 10, 0);
        }
      }
      else {
        if(new_y2 > new_y1) {
          rotate(-theta - PI / 2);
          line(-10, 0, 10, 0);
        }
        else {
          rotate(theta + PI / 2);
          line(-10, 0, 10, 0);
        }
      }
      popMatrix();
  }

  
  
 
}

class Intensity{
   int i;
   String type;
   float value;
   
   public Intensity(int i, String type, float value) {
    this.i = i;
    this.type = type;
    this.value = value;
   }
}

class Node {
  String name, state;
  int n_genes;
  float a, b;
  float[] g, h, center;
  
  public Node(String name, int n_genes, float a, float b, float[] g, float[] h, float[] center, String state) {
    this.name = name;
    this.n_genes = n_genes;
    this.a = a;
    this.g = g;
    this.b = b;
    this.h = h;
    this.center = new float[2];
    this.center[0] = center[0] + start_pos_x;
    this.center[1] = center[1] + start_pos_y;
    this.state = state;
  }
  
  public Node(String name, int n_genes, float a, float g, float[] b, float[] h, float[] center) {
   this(name, n_genes, a, g, b, h, center, "inactive");
  }
  
  public int[] incoming_g() {
    int[] nodes_g = new int[n_genes];
    for(int i = 0; i < this.n_genes; i++) {
      if (this.g[i] != 0) {
         nodes_g[i] = i; 
      }
    }
    return nodes_g;
  }
  
  public int[] incoming_h() {
    int[] nodes_h = new int[n_genes];
    for(int i = 0; i < this.n_genes; i++) {
      if (this.h[i] != 0) {
         nodes_h[i] = i; 
      }
    }
    return nodes_h;
  }
  
  public void draw_node(float diameter) {
     if(this.state == "active") {
        stroke(0); 
        fill(42, 81, 93); // 42, 81, 93
        ellipse(this.center[0] + start_pos_x, this.center[1] + start_pos_y, diameter, diameter);
     }
     else if(this.state == "done") {
        stroke(0);
        fill(239, 246, 255);
        ellipse(this.center[0] + start_pos_x, this.center[1] + start_pos_y, diameter, diameter);
     }
     
  }
  
  public void draw_edges(float radius, Node[] nodes, int[] incoming_nodes, boolean grow_line, String type) {
    for(int i=0; i < incoming_nodes.length; i++) {
      if(incoming_nodes[i] != 0) {
        int node = incoming_nodes[i];
        float[] updated_center1 = {nodes[node].center[0] + start_pos_x, nodes[node].center[1] + start_pos_y};
        float[] updated_center2 = {this.center[0] + start_pos_x, this.center[1] + start_pos_y};
        draw_arrow(radius, updated_center1, updated_center2, grow_line, type); 
      }
    }
  }
}

void display_node(float x, float y) {
   float[] cur_center = null;
   for(int i=0; i < centers.length; i++) {
     float[] center = centers[i];
     float d = dist(x, y, (center[0] + start_pos_x) * zoom, (center[1] + start_pos_y) * zoom);
     float r = radius;
     fill(0);
     if(d < r) {
          cur_center = center;
          break;
      }
   }
   
   if(cur_center == null) {
      return; 
   }
   
   
   for(int i = 0; i < nodes.length; i++) {
     Node node = nodes[i];
     if(cur_center[0] == node.center[0] && cur_center[1] == node.center[1] && node.state != "inactive") {
        pushMatrix();
        translate(x, y);
        stroke(0);
        fill(255, 200);
        rect(0, 0, 172, 39);
        fill(0);
        translate(5, 33);
        textFont(text_font);
        textSize(22);
        text(node.name, 80 - textWidth(node.name) / 2, -4);
        popMatrix();
     }
     
   }
}