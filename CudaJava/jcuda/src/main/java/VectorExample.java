public class VectorExample {
    static {
        System.loadLibrary("vectorlib"); // loads vectorlib.dll
    }

    public native int sumVector(int[] arr);

    public int sum(int[] data) {
        return sumVector(data);
    }
}
