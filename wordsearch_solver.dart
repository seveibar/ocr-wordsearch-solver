
#import('dart:html');
#import('dart:math');
#import('dart:isolate');

int sizeX,sizeY;
int errorMax = 1;

List<String> characters;


List<String> lostWords;

CanvasRenderingContext2D context;
CanvasElement canvas;

void main() {
  
  print("Initializing...");
  
  query("#go").on.click.add(solveEvent);
  
  
  //Examples
  
  query("#ex1").on.click.add((e){
    query("#text_input").value = "rbc\nqaa\nybt";
    query("#word_input").value = "rat cat";
    query("#error_max_0").selected = true;
    solve();
  });
  
  query("#ex2").on.click.add((e){
    query("#text_input").value = "CLAWZS\nNFWHPX\nYKLZML\nKITYYY\nVERMHQ\nQHSSJO";
    query("#word_input").value = "KITTY CLAWS";
    query("#error_max_1").selected = true;
    solve();
  });
  
  query("#ex3").on.click.add((e){
    query("#text_input").value = "AURLPJLKAAMBCZH\nCTEUORLUJPMYZWH\nSRBJSMEDLCIWIUT\nBVMMQBYBYXJHKFY\nPBERABRMMEMBHEQ\nRKVHHSABGEKQDBI\nXLOLCMUSESCEERP\nADNJRANOYEWEAUU\nBUBUAYACVPWNDAQ\nQLCKMJJTYTHXNRF\nRWEGPUUOKENUJYV\nSNLHCLGBHMZQMXH\nKULFAYTEFBTDTPT\nTSUGUAERTEZWKBU\nEUJWQZZENRJTYEJ";
    query("#word_input").value = "FEBRUARY\nOCTOBER\nNOVEMBER\nJANUARY\nMAY\nMARCH\nSEPTEMBER\nAUGUST\nJUNE\nDECEMBER\nJULY";
    query("#error_max_0").selected = true;
    solve();
  });
  
}

Function drawPuzzle(){
  final int margin = 20;
  final int wsx = canvas.width - margin * 2;
  final int wsy = canvas.height - margin * 2;
  final num usx = wsx / sizeX;
  final num usy = wsy / sizeY;
  
  //Draw all the letters
  context.globalAlpha = 1;
  context.fillStyle = "#fff";
  context.fillRect(0,0,canvas.width,canvas.height);
  context.fillStyle = "#000";
  context.font = "14px Arial";
  for (int y= 0;y<sizeY;y++){
    for (int x = 0;x<sizeX;x++){
      context.fillText(characters[x + y * sizeX], x * usx + usx/2 + margin, y * usy + usy/2 + margin);
    }
  }
  
  //Return a function to highlight
  return (int fx,int fy,int tx,int ty){
    context.lineWidth = usx/4+10;
    context.strokeStyle = "#333";
    context.lineCap = "round";
    context.textAlign = "center";
    context.globalAlpha = .25;
    context.beginPath();
    context.moveTo(fx * usx + margin + usx/2, fy * usy + margin + usy/2);
    context.lineTo(tx * usx + margin + usx/2, ty * usy + margin + usy/2);
    context.stroke();
    context.closePath();
  };
  
}

void solveEvent(e){
  solve();
}

void solve(){
  print("Clicked");
  errorMax = parseInt(query("#error_max").value);
  String text = query("#text_input").value.toUpperCase().replaceAll(" ", "");
  
  //Determine shortest line
  List<String> rawLines = text.split("\n");
  sizeX = 9999;
  rawLines.forEach((String s){
    if (s.length < sizeX){
      sizeX = s.length;
    }
  });
  List<String> tf = new List<String>();
  text.split("\n").forEach((String line){
    tf.add(line.substring(0, sizeX));
  });
  
  text = Strings.join(tf, "");
  characters = text.splitChars();
  sizeY = characters.length ~/ sizeX;
  List<String> wordLines = query("#word_input").value.toUpperCase().split("\n");
  lostWords = new List<String>();
  wordLines.forEach((String line){
    lostWords.addAll(line.split(" "));
  });
  
  
  canvas = query("#canvas");
  context = canvas.getContext("2d");
  
  final Function draw = drawPuzzle();
  
  lostWords.forEach((String word){
    try{
      highlightWord(word,draw);
    } catch(e){
      print("Error with $word");
    }
  });
}

void highlightWord(String word,Function draw){
  List<String> wc = word.splitChars();
  final List<int> next = [-1,1,-sizeX,sizeX,-sizeX+1,-sizeX-1,sizeX+1,sizeX-1];
  for (int i = 0;i<characters.length;i++){
    if (characters[i] == wc[0]){
      for (int u = 0;u<next.length;u++){
        int index = wordTouch(i,wc,1,next[u]);
        if (index != null){
          draw(i%sizeX,i~/sizeX,index%sizeX,index~/sizeX);
          return;
        }
      }
    }
  }
}

int wordTouch(int index,List<String> chars,int offset,int direction,[int errorCount = 0]){
  //print("Checking $index for ${chars[offset]}");
  //If the next character is next-to, continue search until entire word is found and return final index
  //If next character is not next-to, return null
  if (offset >= chars.length){
    return index;
  }
  String letter = chars[offset];
  int ci = index + direction;
  if (ci >= 0 && ci < characters.length){
    //print("$ci ${characters[ci]} == ${chars[offset]}");
    if (characters[ci] == letter){
      if (offset+1 >= chars.length){
        return ci;
      }else{
        int res = wordTouch(ci,chars,offset+1,direction,errorCount);
        if (res != null){
          return res;
        }
      }
    }
  }
  if (errorCount < errorMax){
    int res = wordTouch(ci,chars,offset+1,direction,errorCount+1);
    if (res != null){
      return res;
    }
  }
  return null;
}

/*
int wordTouch(int index,List<String> chars,int offset,int direction){
  print("Checking $index for ${chars[offset]}");
  //If the next character is next-to, continue search until entire word is found and return final index
  //If next character is not next-to, return null
  if (offset >= chars.length){
    return index;
  }
  String letter = chars[offset];
  int ci = index + direction;
  if (ci >= 0 && ci < characters.length){
    print("$ci ${characters[ci]} == ${chars[offset]}");
    if (characters[ci] == letter){
      if (offset+1 >= chars.length){
        return ci;
      }else{
        int res = wordTouch(ci,chars,offset+1,direction);
        if (res != null){
          return res;
        }
      }
    }
  }
  return null;
}
*/