public class Main {
    public static void main(String[] args) {
        int[] data = {1, 2, 3, 4, 100};
        VectorExample javacpp = new VectorExample();
        int result = javacpp.sum(data);
        System.out.println("result: " +  result );
    }
}
