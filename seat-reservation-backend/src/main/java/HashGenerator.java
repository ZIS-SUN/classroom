import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class HashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hash = encoder.encode("admin123");
        System.out.println("Hash for 'admin123': " + hash);

        // 验证现有哈希
        String existingHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEIUi";
        boolean matches = encoder.matches("admin123", existingHash);
        System.out.println("Does 'admin123' match existing hash: " + matches);
    }
}