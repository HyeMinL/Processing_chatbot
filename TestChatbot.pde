import java.util.List;
import java.util.ArrayList;
import javax.net.ssl.HttpsURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.ProcessBuilder;
import processing.core.PVector;



 
ChatBot chatBot;

void setup() {
  size(1000, 800);
  chatBot = new ChatBot(this, "openai_query.py", "bot_high_res.png", "user.png");
}

void draw() {
  background(255);
  chatBot.display();
  if(chatBot.showEffect){
     if(chatBot.sentiment.equals("negative")){
         chatBot.displayRaindrops();
     
     }else{
         chatBot.displayEffect();
     }
     
    
    
  }
}

void mousePressed() {
  chatBot.handleMousePressed(mouseX, mouseY);
}

void keyPressed() {
  chatBot.handleKeyPressed(key, keyCode);
}

void mouseWheel(MouseEvent event) {
  chatBot.handleMouseWheel(event.getCount());
}
