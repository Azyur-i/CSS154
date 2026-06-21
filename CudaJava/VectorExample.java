public class VectorExample {
    static {
        System.loadLibrary("vectorlib"); // loads vectorlib.dll
    }

    public native int sumVector(int[] arr);

    public static void main(String[] args) {
        VectorExample ve = new VectorExample();
        int[] data = {1, 2, 3, 4, 5};
        int result = ve.sumVector(data);
        System.out.println("Sum of vector: " + result);
    }
}
