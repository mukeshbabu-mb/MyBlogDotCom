-- Create Database if not Exist
CREATE DATABASE IF NOT EXISTS MyBlogDotCom_DB;

USE MyBlogDotCom_DB;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    category_short_description VARCHAR(200)
);

-- Insert default category "others" and prevent its hard removal
INSERT INTO categories (category_name, category_short_description)
VALUES ('others', 'Default category for uncategorized posts')
ON DUPLICATE KEY UPDATE category_name=category_name;

-- Add is_deleted column for soft delete
ALTER TABLE categories ADD COLUMN is_deleted BOOLEAN NOT NULL DEFAULT FALSE;

-- Create a trigger to prevent hard deletion of "others" category, but allow soft delete
DELIMITER $$
CREATE TRIGGER prevent_others_category_hard_deletion
BEFORE DELETE ON categories
FOR EACH ROW
BEGIN
    IF OLD.category_name = 'others' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot hard delete the default "others" category. Use soft delete instead.';
    END IF;
END$$
DELIMITER ;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    post_title VARCHAR(200) NOT NULL,
    post_slug VARCHAR(200) UNIQUE NOT NULL,
    post_content TEXT NOT NULL,
    category_id INT DEFAULT 1,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE post_tags (
    post_tag_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    tag_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

-- Sample categories
INSERT INTO categories (category_name, category_short_description) VALUES
('technology', 'Posts about tech and programming'),
('lifestyle', 'Lifestyle tips and stories'),
('travel', 'Travel experiences and guides');

-- Sample tags
INSERT INTO tags (tag_name) VALUES
('python'),
('javascript'),
('webdev'),
('health'),
('adventure');

-- Sample posts
INSERT INTO posts (post_title, post_slug, post_content, category_id, status) VALUES
('Getting Started with Python', 'getting-started-python', 'Learn the basics of Python programming.', 1, 'published'),
('10 Tips for a Healthy Lifestyle', '10-tips-healthy-lifestyle', 'Simple tips to improve your daily life.', 2, 'published'),
('Exploring the Alps', 'exploring-the-alps', 'A travel guide to the Alps.', 3, 'published'),
('JavaScript for Beginners', 'javascript-for-beginners', 'Introduction to JavaScript.', 1, 'draft');

-- Sample post_tags (associating posts and tags)
INSERT INTO post_tags (post_id, tag_id) VALUES
(1, 1), -- Python post tagged with 'python'
(1, 3), -- Python post tagged with 'webdev'
(2, 4), -- Lifestyle post tagged with 'health'
(3, 5), -- Alps post tagged with 'adventure'
(4, 2), -- JS post tagged with 'javascript'
(4, 3); -- JS post tagged with 'webdev'


