
String mode, game_state, medicine_state;
int level;
Node[] nodes;
Drug[] drugs;
int budget;
int[][] adj_matrix;
int[][] adj_matrix_checker;
boolean game_setup_done;
Node selected_node;
PImage red_pill, blue_pill, start_screen_network;
PFont header_font, text_font, text_font_2;
float start_screen_angle;

void setup() {
	size(1200, 800, P2D);
	mode = "start";
	level = 1;
	game_setup_done = false;
	game_state = "default";
	start_screen_angle = 0;

	header_font = createFont("./assets/fonts/Oswald-Regular.ttf", 48);
    text_font = createFont("./assets/fonts/Oxygen-Regular.ttf", 48);
    text_font_2 = createFont("./assets/fonts/Oswald-Light.ttf", 48);

	red_pill = loadImage("./assets/img/red_pill.png");
	blue_pill = loadImage("./assets/img/blue_pill.png");
	start_screen_network = loadImage("./assets/img/start_screen.png");
}

void draw() {
	background(255);
	textFont(text_font);
	if(mode == "start") {
		start_screen();
	}
	else if(mode == "level") {
		level_screen();
		game_setup_done = false;
	}
	else if(mode == "game") {
		game_screen();
	} 
	else if(mode == "finish") {
		finish_screen();
	}
}

void finish_screen() {
	textSize(30);
	text("Congratulations!", width/2  - textWidth("Congratulations!")/2, height/2);
	textSize(25)
	text("You've beaten the game!", width/2  - textWidth("You've beaten the game!")/2, height/2 + 80);
}

void start_screen() {
	fill(0);
	pushMatrix();
	translate(width/2, height/2 - 150);
	rotate(start_screen_angle);
	imageMode(CENTER);
	image(start_screen_network, 0, 0, 400, 400);
	popMatrix();
	textSize(30)
	text("Start Game", width/2  - textWidth("Start Game")/2, height/2 + 80);
	noFill();
	rect(width/2  - textWidth("Start Game")/2 - 5, height/2 + 50, textWidth("Start Game") + 10, 40);
	start_screen_rotate();
}

void start_screen_rotate() {
	start_screen_angle += 0.02;
}

void level_screen() {
	text("LEVEL SCREEN", 500, 500);
}

void game_screen() {
	if(!game_setup_done) {
		setup_game_elements();
		game_setup_done = true;
	}
	if(game_state == "update_nodes") {
		for(int i = 0; i < drugs.length; i++) {
			if(medicine_state == drugs[i].type) {
				budget -= drugs[i].value;
			}
		}
		if(budget > 0) {
			for(int i = 0; i < adj_matrix.length; i++) {
				for(int j = 0; j < adj_matrix.length; j++) {
					adj_matrix_checker[i][j] = adj_matrix[i][j];
				}
			}
			if(medicine_state == "A") {
				update_nodes(selected_node, 1);
			}
			else {
				update_nodes(selected_node, -1);
			}
			
			int sum = 0;
			for(int i = 0; i < nodes.length; i++) {
				nodes[i].state = "default";
				sum += abs(nodes[i].value);
			}
			drugs[0].selected = false;
			drugs[1].selected = false;

			if(sum == 0) {
				game_state = "win";
				if (level + 1 > 5) {
					mode = "finish";
				}
			}
			else {
				game_state = "default";
			}
		}
		else {
			game_state = "lose";
		}
		
	}

	draw_edges();
	for(int i = 0; i < nodes.length; i++) {
		nodes[i].draw();
	}
	drugs[0].draw();
	drugs[1].draw();

	// UI
	fill(0);
	text("Supply:", 200, 625);
	textSize(30)
	text(budget, 230 - textWidth(budget)/2, 660);

	draw_game_ui();

	if(game_state == "win") {
		draw_win_prompt();
	}
}

void draw_win_prompt() {
	fill(255);
	rect(250, 300, 500, 200);

	rect(295, 370, 130, 50);
	rect(455, 370, 115, 50);
	rect(595, 370, 105, 50);

	fill(0);
	textFont(text_font);
	textSize(20);
	text("Repeat Level", 300, 400);
	text("Level Menu", 460, 400);
	text("Next Level", 600, 400);
}

void click_win_prompt() {
	if(mouseX > 295 && mouseX < 425 && mouseY > 370 && mouseY < 420) {
		game_setup_done = false;
		game_state = "default";
	}

	if(mouseX > 455 && mouseX < 570 && mouseY > 370 && mouseY < 420) {
		mode = "level";
		game_setup_done = false;
		game_state = "default";
	}

	if(mouseX > 595 && mouseX < 700 && mouseY > 370 && mouseY < 420) {
		level += 1;
		game_setup_done = false;
		game_state = "default";
	}
}

void click_game_ui() {
	if(mouseX > 740 && mouseX < 860 && mouseY > 615 && mouseY < 665) {
		game_setup_done = false;
		game_state = "default";
	}
	if(mouseX > 50 && mouseX < 150 && mouseY > 50 && mouseY < 80) {
		level -= 1;
		game_setup_done = false;
		game_state = "default";
	}
}

void draw_game_ui() {
	stroke(0);
	fill(255);
	strokeWeight(3);
	// restart
	rect(740, 615, 120, 50);

	//prev level
	if(level > 1) {
		rect(50, 50, 100, 30);
	}
	

	fill(0);
	text("Restart", 750, 650);

	textSize(20);
	if(level > 1) {
		text("Previous", 60, 75);
	}
}

void update_nodes(Node curr_node, int value) {
	int curr_node_index = curr_node.index;
	int[] connections = adj_matrix[curr_node_index];
	int[] check_connections = adj_matrix_checker[curr_node_index];
	if(curr_node.type != "Med") {
		curr_node.value += value;
	}
	for(int i = 0; i < connections.length; i++) {
		if(connections[i] != 0 && check_connections[i] != 0) {
			int new_value = connections[i]*value;
			adj_matrix_checker[curr_node_index][i] = 0;
			update_nodes(nodes[i], new_value);
		}
	}
}


void setup_game_elements() {
	String level_file = "./data/level_" + level.toString() + ".txt";
	String[] data = loadStrings(level_file);
	int pointer = 0;

	String[] init_values = data[pointer].split(" ");
	int num_med_nodes = int(init_values[0]);
	int num_reg_nodes = int(init_values[1]);
	int total_nodes = num_med_nodes + num_reg_nodes;
	nodes = new Node[total_nodes];
	for(int i = 0; i < num_med_nodes; i++) {
		String[] values = data[pointer+i+1].split(" ");
		nodes[i] = new Node(values[0], i, {float(values[1]), float(values[2])}, "Med", 0);
	}

	pointer += num_med_nodes + 1;

	for(int i = num_med_nodes; i < total_nodes; i++) {
		String[] values = data[pointer+i-num_med_nodes].split(" ");
		nodes[i] = new Node(values[0], i, {float(values[2]), float(values[3])}, "Reg", int(values[1]));
	}

	pointer += num_reg_nodes + 1;

	adj_matrix = new int[total_nodes][total_nodes];
	adj_matrix_checker = new int[total_nodes][total_nodes];

	int num_connections = int(data[pointer]);
	for(int i = 0; i < num_connections; i++) {
		String[] values = data[pointer+i+1].split(" ");
		int index1 = get_index_of_node_name(values[0]);
		int index2 = get_index_of_node_name(values[1]);
		int value = int(values[2]);
		adj_matrix[index1][index2] = value;
	}

	pointer += num_connections + 2;
	drugs = new Drug[2];
	int activation_drug_price = int(data[pointer]);
	drugs[0] = new Drug("A", activation_drug_price);
	int inhibition_drug_price = int(data[pointer+1]);
	drugs[1] = new Drug("I", inhibition_drug_price);
	budget = int(data[pointer+2]);
}

void draw_edges(){
	for(int i = 0; i < adj_matrix.length; i++) {
		for(int j = 0; j < adj_matrix.length; j++) {
			int value = adj_matrix[i][j];
			if(value != 0) {
				strokeWeight(3);
				float[] from = nodes[i].mid_coordinates;
				float[] to = nodes[j].mid_coordinates;
				stroke(0);
				draw_arrow(40, from, to);
				fill(0);
				ellipse((from[0]+to[0])/2, (from[1]+to[1])/2, 32, 32);
				fill(255);
				textSize(15);
				text(value, (from[0]+to[0])/2-4, (from[1]+to[1])/2 + 3);
			}
		}
	}
}

void mousePressed() {
	if(mode == "start") {
		if(mouseX > width/2  - textWidth("Start Game")/2 - 5 && mouseX < textWidth("Start Game") + 10 + width/2  - textWidth("Start Game")/2 - 5 && mouseY > height/2 + 50 && mouseY < height/2 + 50 + 40) {
			mode = "game";
		}
	}
	if(mode == "game") {
		click_game_ui();
		for(int i = 0; i < nodes.length; i++) {
			nodes[i].select();
		}
		drugs[0].select();
		drugs[1].select();
		if(game_state == "win") {
			click_win_prompt();
		}
	}
}

int get_index_of_node_name(String name) {
	for(int i = 0; i < nodes.length; i++) {
		String node_name = nodes[i].name;
		if(node_name == name) {
			return nodes[i].index;
		}
	}
}

void draw_arrow(float radius, float[] center_circ1, float[] center_circ2) { 
  float x1 = center_circ1[0];
  float y1 = center_circ1[1];
  float x2 = center_circ2[0];
  float y2 = center_circ2[1];
  float dist_bet_circs = dist(x1, y1, x2, y2);
  
  float new_x1, new_x2, new_y1, new_y2;
  if(x1 < x2) {
    new_x1 = x1 + radius / dist_bet_circs * (x2 - x1);
    new_x2 = x2 - radius / dist_bet_circs * (x2 - x1);
  }
  else {
    new_x1 = x1 - radius / dist_bet_circs * (x1 - x2);
    new_x2 = x2 + radius / dist_bet_circs * (x1 - x2);
  }
  if(y1 > y2) {
    new_y1 = y1 + radius / dist_bet_circs * (y2 - y1);
    new_y2 = y2 - radius / dist_bet_circs * (y2 - y1);
  }
  else {
    new_y1 = y1 - radius / dist_bet_circs * (y1 - y2);
    new_y2 = y2 + radius / dist_bet_circs * (y1 - y2);
  }
  
  line(new_x1, new_y1, new_x2, new_y2);
  
  pushMatrix();
  translate(new_x2, new_y2);
  float theta = acos((new_x1 - new_x2)/dist(new_x1, new_y1, new_x2, new_y2));
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
  popMatrix();
}

public interface Drawable {
	public void draw();
}

public interface Selectable {
	public void select();
}

class Node implements Drawable, Selectable {
	String name, type, state;
	float coordinates;
	float mid_coordinates;
	int value;
	int index;
	int[] color;
	boolean selected;
	public Node(String name, int index, float coordinates, String type, int value) {
		this.name = name;
		this.index = index;
		this.coordinates = coordinates;
		this.type = type;
		if(type == "Med") {
			this.mid_coordinates = {coordinates[0] + 40, coordinates[1] + 40};
		}
		else {
			this.mid_coordinates = coordinates;
		}
		this.value = value;
		this.highlight = false;
		this.color = {230, 236, 246};
		this.selected = false;
		this.state = "default";
	}

	public void draw() {
		strokeWeight(3);
		if(game_state == "select_node" && this.type == "Med") {
			if(medicine_state == "A") {
				stroke(0);
				fill(112,171,175);
			}
			else {
				stroke(0);
				fill(193,0,1);
			}
		}
		else {
			fill(this.color[0], this.color[1], this.color[2]);
			stroke(0);
		}
		if(this.type == "Med"){
			rect(this.coordinates[0], this.coordinates[1], 80, 80);
		}
		else {
			ellipse(this.coordinates[0], this.coordinates[1], 80, 80);
			fill(0);
			textSize(20)
			text(value, this.mid_coordinates[0]-10, this.mid_coordinates[1]+5)
		}
		if(selected) { 
			this.color = {230, 236, 246};
			selected = false; 
		}


	}

	public void select() {
		float distance_x = abs(mouseX - mid_coordinates[0]);
		float distance_y = abs(mouseY - mid_coordinates[1]);
		if(this.type == "Med" && game_state == "select_node") {
			if (distance_x < 40 && distance_y < 40) {
				this.color[0] = 0;
				this.color[1] = 0;
				this.color[2] = 0;
				selected = true;
				game_state = "update_nodes";
				selected_node = this;
			}
		}
	}
}

class Drug implements Drawable, Selectable {
	String type;
	int value;
	int[] color;
	int[] mid_coordinates, coordinates;
	boolean selected;
	public Drug(String type, int value) {
		this.type = type;
		this.value = value;
		if(type == "I") {
			color = {0, 0, 0};
			coordinates = {350, 600};
		}
		else {
			color = {255, 255, 255};
			coordinates = {550, 600};
		}
		this.mid_coordinates = {coordinates[0] + 40, coordinates[1] + 40};
	}

	public void draw() {
		
		strokeWeight(5);
		if(selected && this.type == medicine_state) {
			if(type == "A") {
				stroke(112,171,175);
			}
			else {
				stroke(193,0,1);
			}
		}
		else {
			stroke(0);
		}
		fill(this.color[0], this.color[1], this.color[2]);
		rect(coordinates[0], coordinates[1], 80, 80);
		
		imageMode(CORNER);
		if(type == "A") {
			image(blue_pill, coordinates[0], coordinates[1], 80, 80);
		}
		else {
			image(red_pill, coordinates[0], coordinates[1], 80, 80);
		}
  		

	}

	public void select() {
		float distance_x = abs(mouseX - mid_coordinates[0]);
		float distance_y = abs(mouseY - mid_coordinates[1]);
		if(distance_x < 40 && distance_y < 40) {
			if(game_state == "default" || game_state == "select_node") {
				if(type == "I") {
					this.color[0] = 255;
					this.color[1] = 255;
					this.color[2] = 255;
					medicine_state = "I";
				}
				else {
					this.color[0] = 0;
					this.color[1] = 0;
					this.color[2] = 0;
					medicine_state = "A";
				}
				selected = true;
				game_state = "select_node";
			}
			
		}
	}
}