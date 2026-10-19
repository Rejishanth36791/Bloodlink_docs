package lk.bloodlink.model.entity;

import lk.bloodlink.model.enums.BloodType;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.usertype.UserType;

import java.io.Serializable;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Objects;

public class BloodTypeUserType implements UserType<BloodType> {

    @Override
    public int getSqlType() {
        return Types.VARCHAR;
    }

    @Override
    public Class<BloodType> returnedClass() {
        return BloodType.class;
    }

    @Override
    public boolean equals(BloodType x, BloodType y) {
        return Objects.equals(x, y);
    }

    @Override
    public int hashCode(BloodType x) {
        return Objects.hashCode(x);
    }

    @Override
    public BloodType nullSafeGet(ResultSet rs, int position, SharedSessionContractImplementor session, Object owner)
            throws SQLException {
        String text = rs.getString(position);
        return text == null ? null : BloodType.fromValue(text);
    }

    @Override
    public void nullSafeSet(PreparedStatement st, BloodType value, int index, SharedSessionContractImplementor session)
            throws SQLException {
        if (value == null) {
            st.setNull(index, Types.VARCHAR);
        } else {
            st.setString(index, value.getValue());
        }
    }

    @Override
    public BloodType deepCopy(BloodType value) {
        return value;
    }

    @Override
    public boolean isMutable() {
        return false;
    }

    @Override
    public Serializable disassemble(BloodType value) {
        return value == null ? null : value.name();
    }

    @Override
    public BloodType assemble(Serializable cached, Object owner) {
        return cached == null ? null : BloodType.valueOf((String) cached);
    }

    @Override
    public BloodType replace(BloodType detached, BloodType managed, Object owner) {
        return detached;
    }
}
