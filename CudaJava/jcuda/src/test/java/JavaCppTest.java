import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class JavaCppTest {

    @Test
    void testJavaCpp() {
        int[] data = {1, 2, 3, 4, 5};
        VectorExample javacpp = new VectorExample();
        int result = javacpp.sumVector(data);
        assertEquals(15, result, "2 + 3 should equal 5");
    }
}
