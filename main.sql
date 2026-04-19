CREATE TABLE Users (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE Roles (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE UserRoles (
    id INT PRIMARY KEY,
    user_id INT,
    role_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (role_id) REFERENCES Roles(id)
);

CREATE TABLE Permissions (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE RolePermissions (
    id INT PRIMARY KEY,
    role_id INT,
    permission_id INT,
    FOREIGN KEY (role_id) REFERENCES Roles(id),
    FOREIGN KEY (permission_id) REFERENCES Permissions(id)
);

INSERT INTO Roles (id, name) VALUES (1, 'admin');
INSERT INTO Roles (id, name) VALUES (2, 'moderator');
INSERT INTO Roles (id, name) VALUES (3, 'user');

INSERT INTO Permissions (id, name) VALUES (1, 'create_post');
INSERT INTO Permissions (id, name) VALUES (2, 'edit_post');
INSERT INTO Permissions (id, name) VALUES (3, 'delete_post');

INSERT INTO RolePermissions (id, role_id, permission_id) VALUES (1, 1, 1);
INSERT INTO RolePermissions (id, role_id, permission_id) VALUES (2, 1, 2);
INSERT INTO RolePermissions (id, role_id, permission_id) VALUES (3, 1, 3);
INSERT INTO RolePermissions (id, role_id, permission_id) VALUES (4, 2, 1);
INSERT INTO RolePermissions (id, role_id, permission_id) VALUES (5, 2, 2);

CREATE FUNCTION has_permission(user_id INT, permission_name VARCHAR(255)) RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1
        FROM UserRoles ur
        JOIN RolePermissions rp ON ur.role_id = rp.role_id
        JOIN Permissions p ON rp.permission_id = p.id
        WHERE ur.user_id = user_id AND p.name = permission_name
    );
$$ LANGUAGE SQL;

CREATE PROCEDURE create_user(name VARCHAR(255), email VARCHAR(255), role_name VARCHAR(255)) AS $$
    INSERT INTO Users (id, name, email) VALUES (DEFAULT, name, email);
    INSERT INTO UserRoles (id, user_id, role_id) VALUES (DEFAULT, (SELECT id FROM Users WHERE email = email), (SELECT id FROM Roles WHERE name = role_name));
$$ LANGUAGE SQL;

CREATE PROCEDURE assign_role(user_id INT, role_name VARCHAR(255)) AS $$
    INSERT INTO UserRoles (id, user_id, role_id) VALUES (DEFAULT, user_id, (SELECT id FROM Roles WHERE name = role_name));
$$ LANGUAGE SQL;

CREATE PROCEDURE remove_role(user_id INT, role_name VARCHAR(255)) AS $$
    DELETE FROM UserRoles WHERE user_id = user_id AND role_id = (SELECT id FROM Roles WHERE name = role_name);
$$ LANGUAGE SQL;