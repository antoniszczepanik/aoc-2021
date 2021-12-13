import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

class Main {

    public static void main(String[] args){
        if (args.length < 1) {
            System.err.println("Provide name of a file you'd like to solve");
            System.exit(1);
        }
        Input input = new Input(args[0]);
        System.out.println("Day 13:");
        System.out.printf("Solution 1: %d\n", solution1(input));
        System.out.println("Solution 2:");
        printCoords(solution2(input));
    }

    private static int solution1(Input input){
        Fold f = input.folds.get(0);
        HashSet<Coord> new_coords = new HashSet<Coord>();
        for (Iterator<Coord> i = input.coords.iterator(); i.hasNext();) {
            Coord c = i.next();
            if (f.alongX){
                new_coords.add(translateX(c, f.value));
            } else {
                new_coords.add(translateY(c, f.value));
            }
        }
        return new_coords.size();
    }

    private static HashSet<Coord> solution2(Input input){
        HashSet<Coord> old_coords = input.coords;
        for (Fold f : input.folds) {
            HashSet<Coord> new_coords = new HashSet<Coord>();
            for (Iterator<Coord> i = old_coords.iterator(); i.hasNext();) {
                Coord c = i.next();
                if (f.alongX){
                    new_coords.add(translateX(c, f.value));
                } else {
                    new_coords.add(translateY(c, f.value));
                }
            }
            old_coords = new_coords;

        }
        return old_coords;

    }

    private static Coord translateX(Coord c, int x){
        if (c.x < x){
            return c;
        }
        return new Coord(x-(c.x-x), c.y);
    }

    private static Coord translateY(Coord c, int y){
        if (c.y < y){
            return c;
        }
        return new Coord(c.x, y-(c.y-y));
    }

    private static void printCoords(HashSet<Coord> coords){
        // Get min and max.
        int min_x, min_y, max_x, max_y;
        min_x = min_y = Integer.MAX_VALUE;
        max_x = max_y = Integer.MIN_VALUE;
        for (Coord c : coords) {
            min_x = Math.min(min_x, c.x);
            min_y = Math.min(min_y, c.y);
            max_x = Math.max(max_x, c.x);
            max_y = Math.max(max_y, c.y);
        }
        for (int i = min_y; i < max_y+1; i++){
            for (int j = min_x; j< max_x+1; j++){
                System.out.printf("%s", coords.contains(new Coord(j, i)) ? "#" : ".");
            }
            System.out.printf("\n");
        }
    }


}

class Coord {
    public int x, y;
    public Coord(int x_val, int y_val){
        x = x_val;
        y = y_val;
    }

    // Requ
    @Override
    public boolean equals(Object o) {
        if (o == null) {
            return false;
        }
        if (this == o) {
            return true;
        }
        if (!(o instanceof Coord)){
            return false;
        }
        Coord other = (Coord)o;
        if ((other.x == this.x) && (other.y == this.y)) {
            return true;
        }   
        return false;
    }
 
    @Override
    public int hashCode() {
        // Xs and Ys don't seem to be larger than 10K.
        if (this.y > 10000) {
            System.err.printf("y value > 10K: %d", this.y);
            System.exit(1);
        }
        return this.x * 10000 + this.y;
    }
}


class Fold {
    public final boolean alongX;
    public final int value;
    public Fold(boolean isAlongX, int val){
        alongX = isAlongX;
        value = val;
    }
}

class Input {

    public final HashSet<Coord> coords = new HashSet<Coord>();  
    public final List<Fold>     folds  = new ArrayList<Fold>();  

    public Input(String filePath) {
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader(filePath));
            String line = reader.readLine();
            // Parse points.
            while (line != null) {
                if (line.isEmpty()) {
                    line = reader.readLine();
                    break;
                }
                addCoord(line);
                line = reader.readLine();
            }
            // Parse folds.
            while (line != null) {
                addFold(line);
                line = reader.readLine();
            }
            reader.close();
        } catch (IOException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }

    void addCoord(String line){
        String[] splitted = line.split(",");
        if (splitted.length != 2){
            System.err.printf("ERROR: cannot parse coord: '%s'\n", line);
            System.exit(1);
        }
        coords.add(new Coord(Integer.parseInt(splitted[0]),
                             Integer.parseInt(splitted[1])));
    }

    void addFold(String line){
        boolean isAlongX = (line.charAt(11) == 'x');
        String[] splitted = line.split("=");
        if (splitted.length != 2){
            System.err.printf("ERROR: cannot parse fold: '%s'\n", line);
            System.exit(1);
        }
        folds.add(new Fold(isAlongX, Integer.parseInt(splitted[1])));
    }
}
