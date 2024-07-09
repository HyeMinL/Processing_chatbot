import java.io.*;
import java.util.*;
import javax.net.ssl.HttpsURLConnection;
import processing.core.PVector;
import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PImage;

class ChatBot {
  PApplet parent;
  String scriptPath;
  String userInput = "";
  ArrayList<String> chatLog = new ArrayList<String>();
  PFont font;
  boolean inputActive = false;
  PImage botImage;
  PImage userImage;
  PImage heartImage;
  PImage dropImage;
  int scrollOffset = 0;
  int lineHeight = 22;
  int messageGap = 10;
  HashMap<String, PImage> emojiMap;
  String sentiment = "neutral";
  boolean showEffect = false;
  ArrayList<PVector> particles = new ArrayList<PVector>();

  Drop[] drops = new Drop[100];
  Heart[] hearts = new Heart[100];
  int totalDrops = 0;
  int totalHearts = 0;

  ChatBot(PApplet p, String script, String botImagePath, String userImagePath) {
    parent = p;
    scriptPath = parent.sketchPath(script);
    font = parent.createFont("Arial", 14);
    parent.textFont(font);
    chatLog.add("Bot: Welcome! How can I help you today?");
    botImage = parent.loadImage(botImagePath);
    userImage = parent.loadImage(userImagePath);
    loadEmojis();
    initializeDrops();
    initializeHearts();
  }

  void loadEmojis() {
    emojiMap = new HashMap<String, PImage>();
    emojiMap.put(":-)", parent.loadImage("smile.png"));
    emojiMap.put("TT", parent.loadImage("sad.png"));
    emojiMap.put(":-(", parent.loadImage("angry.png"));
     emojiMap.put(":surprised:", parent.loadImage("surprised.png"));
  }

  void initializeDrops() {
    for (int i = 0; i < drops.length; i++) {
      drops[i] = new Drop(parent);
    }
  }

  void initializeHearts() {
    for (int i = 0; i < hearts.length; i++) {
      hearts[i] = new Heart(parent);
    }
  }

  void display() {
    displayChatLog();
    drawInputField();
  }

  void displayChatLog() {
    parent.fill(0);
    parent.textSize(14);
    parent.textLeading(lineHeight);
    int y = 20 - scrollOffset;
    for (String line : chatLog) {
      if (line.startsWith("Bot: ")) {
        parent.image(botImage, 10, y - 30, 40, 40);
        String[] wrappedText = wrapText(line.substring(5), parent.width - 60);
        for (String textLine : wrappedText) {
          displayTextWithEmojis(textLine, 50, y);
          y += parent.textAscent() + parent.textDescent() + 15;
        }
      } else if (line.startsWith("User: ")) {
        parent.image(userImage, 10, y - 40, 40, 40);
        String[] wrappedText = wrapText(line.substring(6), parent.width - 60);
        for (String textLine : wrappedText) {
          displayTextWithEmojis(textLine, 60, y);
          y += parent.textAscent() + parent.textDescent() + 15;
        }
      } else {
        String[] wrappedText = wrapText(line, parent.width - 20);
        for (String textLine : wrappedText) {
          displayTextWithEmojis(textLine, 10, y);
          y += parent.textAscent() + parent.textDescent() + 15;
        }
      }
      y += messageGap;
    }
  }

  void displayTextWithEmojis(String text, int x, int y) {
    String[] tokens = text.split(" ");
    int currentX = x;
    for (String token : tokens) {
      if (emojiMap.containsKey(token)) {
        parent.image(emojiMap.get(token), currentX, y - 30, 30, 30);
        currentX += 50;
      } else {
        parent.text(token, currentX, y);
        currentX += parent.textWidth(token + " ");
      }
    }
  }

  String[] wrapText(String text, float maxWidth) {
    List<String> lines = new ArrayList<String>();
    String[] words = text.split(" ");
    StringBuilder currentLine = new StringBuilder(words[0]);

    for (int i = 1; i < words.length; i++) {
      String word = words[i];
      float lineWidth = parent.textWidth(currentLine + " " + word);
      if (lineWidth < maxWidth) {
        currentLine.append(" ").append(word);
      } else {
        lines.add(currentLine.toString());
        currentLine = new StringBuilder(word);
      }
    }
    lines.add(currentLine.toString());

    return lines.toArray(new String[0]);
  }

  void drawInputField() {
    parent.fill(240);
    parent.rect(10, parent.height - 30, parent.width - 20, 20);
    parent.fill(0);
    if (inputActive) {
      parent.fill(0);
    } else {
      parent.fill(150);
    }
    parent.text(userInput, 15, parent.height - 15);
  }

  void handleMousePressed(int mouseX, int mouseY) {
    if (mouseX > 10 && mouseX < parent.width - 10 && mouseY > parent.height - 30 && mouseY < parent.height - 10) {
      inputActive = true;
    } else {
      inputActive = false;
    }
  }

  void handleKeyPressed(char key, int keyCode) {
    if (inputActive) {
      if (key == PApplet.ENTER || key == PApplet.RETURN) {
        processUserInput();
        userInput = "";
      } else if (key == PApplet.BACKSPACE) {
        if (userInput.length() > 0) {
          userInput = userInput.substring(0, userInput.length() - 1);
        }
      } else if (key != PApplet.CODED) {
        userInput += key;
      }
    } else {
      if (key == PApplet.CODED) {
        if (keyCode == PApplet.UP) {
          scrollOffset = Math.max(scrollOffset - 10, 0);
        } else if (keyCode == PApplet.DOWN) {
          scrollOffset += 10;
        }
      }
    }
  }

  void handleMouseWheel(float e) {
    scrollOffset += e * 10;
    scrollOffset = Math.max(scrollOffset, 0);
  }

  void processUserInput() {
    chatLog.add("User: " + userInput);
    String response = getResponse(userInput);
    chatLog.add("Bot: " + response);
    sentiment = getSentiment(userInput);
    adjustScrollOffset();
    showEffect = true;
    createParticles();
  }

  void adjustScrollOffset() {
    int totalHeight = chatLog.size() * (lineHeight + messageGap);
    if (totalHeight > parent.height) {
      scrollOffset = totalHeight - parent.height + 30;
    }
  }

  void createParticles() {
    particles.clear();
    int numParticles = 10;
    for (int i = 0; i < numParticles; i++) {
      particles.add(new PVector(parent.random(parent.width), parent.random(parent.height)));
    }
  }

  void displayEffect() {
    parent.noStroke();
    if (sentiment.equals("positive")) {
      displayHearts();
    } else if (sentiment.equals("negative")) {
      displayRaindrops();
    }
  }

  void displayHearts() {
    for (int i = 0; i < totalHearts; i++) {
      hearts[i].move();
      hearts[i].display();
      if (hearts[i].reachBottom()) {
        totalHearts = 0;
        return;
      }
    }
    hearts[totalHearts] = new Heart(parent);
    totalHearts++;
    if (totalHearts >= hearts.length) {
      totalHearts = 0;
    }
  }

  void displayRaindrops() {
    for (int i = 0; i < totalDrops; i++) {
      drops[i].move();
      drops[i].display();
      if (drops[i].reachBottom()) {
        totalDrops = 0;
        return;
      }
    }
    drops[totalDrops] = new Drop(parent);
    totalDrops++;
    if (totalDrops >= drops.length) {
      totalDrops = 0;
    }
  }

  String getResponse(String input) {
    return runPythonScript(scriptPath, input, "response");
  }

  String getSentiment(String input) {
    return runPythonScript(scriptPath, input, "sentiment");
  }

  String runPythonScript(String scriptPath, String userInput, String mode) {
    StringBuilder output = new StringBuilder();
    try {
      ProcessBuilder pb = new ProcessBuilder("python", scriptPath, userInput, mode);
      pb.redirectErrorStream(true);
      Process p = pb.start();

      BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
      String line;
      while ((line = reader.readLine()) != null) {
        output.append(line).append("\n");
      }
      reader.close();
      p.waitFor();
    } catch (Exception e) {
      e.printStackTrace();
      return "neutral";
    }
    return output.toString().trim();
  }

  class Drop {
    float x, y;
    float speed;
    int c;
    float r;

    Drop(PApplet parent) {
      r = 8;
      x = parent.random(parent.width);
      y = -r * 4;
      speed = parent.random(1, 5);
      c = parent.color(50, 100, 150);
    }

    void move() {
      y += speed;
    }

    void display() {
      parent.fill(c);
      parent.noStroke();
      parent.triangle(x - r, y, x + r, y, x, y - (r * 3));
      parent.ellipse(x, y, r * 2, r * 2);
    }

    boolean reachBottom() {
      return y > parent.height + r * 4;
    }
  }

  class Heart {
    float x, y;
    float speed;
    int c;
    float r;

    Heart(PApplet parent) {
      r = 8;
      x = parent.random(parent.width);
      y = -r * 4;
      speed = parent.random(1, 5);
      c = parent.color(255, 0, 0);
    }

    void move() {
      y += speed;
    }

    void display() {
      parent.fill(c);
      parent.noStroke();
      parent.beginShape();
      parent.curveVertex(x, y + r * 5);
      parent.curveVertex(x, y);
      parent.curveVertex(x - r * 2.5, y - r * 5);
      parent.curveVertex(x - r, y - r * 10);
      parent.curveVertex(x, y - r * 7.5);
      parent.curveVertex(x, y + r * 5);
      parent.endShape();
      
      parent.beginShape();
      parent.curveVertex(x, y + r * 5);
      parent.curveVertex(x, y - r * 7.5);
      parent.curveVertex(x + r, y - r * 10);
      parent.curveVertex(x + r * 2.5, y - r * 5);
      parent.curveVertex(x, y);
      parent.curveVertex(x, y + r * 5);
      parent.endShape();
    }

    boolean reachBottom() {
      return y > parent.height + r * 4;
    }
  }
}
