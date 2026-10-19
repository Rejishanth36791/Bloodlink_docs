package lk.bloodlink.model.enums;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum BloodType {
    A_POS("A+"),
    A_NEG("A-"),
    B_POS("B+"),
    B_NEG("B-"),
    AB_POS("AB+"),
    AB_NEG("AB-"),
    O_POS("O+"),
    O_NEG("O-");

    private final String value;

    BloodType(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static BloodType fromValue(String text) {
        if (text == null) return null;
        String normalized = text.trim();
        for (BloodType b : BloodType.values()) {
            if (b.value.equalsIgnoreCase(normalized) || b.name().equalsIgnoreCase(normalized)) {
                return b;
            }
        }
        String clean = normalized.toUpperCase().replace(" ", "_");
        switch (clean) {
            case "A_POSITIVE", "APOSITIVE" -> { return A_POS; }
            case "A_NEGATIVE", "ANEGATIVE" -> { return A_NEG; }
            case "B_POSITIVE", "BPOSITIVE" -> { return B_POS; }
            case "B_NEGATIVE", "BNEGATIVE" -> { return B_NEG; }
            case "AB_POSITIVE", "ABPOSITIVE" -> { return AB_POS; }
            case "AB_NEGATIVE", "ABNEGATIVE" -> { return AB_NEG; }
            case "O_POSITIVE", "OPOSITIVE" -> { return O_POS; }
            case "O_NEGATIVE", "ONEGATIVE" -> { return O_NEG; }
            default -> {}
        }
        throw new IllegalArgumentException("Unknown blood type: " + text);
    }

    @Override
    public String toString() {
        return this.value;
    }
}
