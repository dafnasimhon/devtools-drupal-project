# DevTools Drupal Project

Final project for the DevTools course: a Drupal website running with Docker and MySQL, including setup, backup, restore, cleanup, Git documentation, and LLM usage documentation.

## Team Members

- Dafna Simhon
- Niv Ivri

## Project Requirements

The project required us to:

- Create a Drupal website using Docker
- Run Drupal together with a MySQL database
- Configure Drupal through the browser
- Create users and initial course-related content
- Back up the Drupal database
- Restore the website from the backup
- Write automation scripts
- Save all project files in a shared GitHub repository
- Write a clear README file
- Document LLM usage in a dedicated `chats` folder

## What We Did

We created a Docker-based Drupal environment with MySQL.

The repository includes scripts for:

- Setting up the Docker environment
- Backing up the Drupal database
- Restoring the Drupal website from a backup
- Cleaning the Docker environment after use

The initial Drupal website was configured with users and course glossary content. A database backup was created so the website can be restored on another machine.

## Technologies Used

- Docker
- Drupal
- MySQL
- Bash
- Git
- GitHub
- gzip
- mysqldump

## Project Files

| File | Description |
| --- | --- |
| `setup.sh` | Creates the Docker network, MySQL container, Drupal container, and database volume |
| `backup.sh` | Creates a compressed backup of the Drupal MySQL database |
| `restore.sh` | Restores the Drupal database from the backup and configures Drupal to connect to MySQL |
| `cleanup.sh` | Removes the Docker containers, volumes, network, and project images |
| `my-drupal.backup.sql.gz` | Database backup file |
| `chats/` | Documentation of LLM usage |

## How to Run and Restore the Project

### 1. Clone the Repository

```bash
git clone https://github.com/dafnasimhon/devtools-drupal-project.git
cd devtools-drupal-project
```

### 2. Give Execution Permissions

```bash
chmod +x setup.sh backup.sh restore.sh cleanup.sh
```

### 3. Start the Docker Environment

```bash
./setup.sh
```

This script creates and starts:

- Docker network: `drupal-network`
- MySQL container: `drupal-db`
- Drupal container: `drupal-app`
- MySQL volume: `drupal-db-data`

You can check that the containers are running with:

```bash
docker ps
```

### 4. Restore the Website

After both containers are running, restore the website from the backup:

```bash
./restore.sh
```

The restore script:

- Checks that the backup file exists
- Waits until MySQL is ready
- Restores the database from `my-drupal.backup.sql.gz`
- Configures Drupal to connect to the MySQL container
- Restarts the Drupal container

### 5. Open the Website

Open the website in a browser:

```text
http://localhost:8080
```

After the restore, the website should open with the users and content that were created before the backup.

## Creating a New Backup

If changes are made to the Drupal website and a new backup is needed, run:

```bash
./backup.sh
```

The default backup file is:

```text
my-drupal.backup.sql.gz
```

After creating a new backup, add and commit it:

```bash
git add my-drupal.backup.sql.gz
git commit -m "Update Drupal backup"
git push
```

## Cleaning the Environment

To remove the Docker resources created for the project, run:

```bash
./cleanup.sh
```

The cleanup script removes:

- Drupal container
- MySQL container
- MySQL volume
- Docker network
- Drupal and MySQL Docker images, if they are not used elsewhere

The backup files remain in the repository so the website can be restored again.

## LLM Usage

LLM usage is documented in the `chats` folder, as required by the assignment.

## Suggested Workflow

A simple full test flow is:

```bash
git clone https://github.com/dafnasimhon/devtools-drupal-project.git
cd devtools-drupal-project
chmod +x setup.sh backup.sh restore.sh cleanup.sh
./setup.sh
./restore.sh
```

Then open:

```text
http://localhost:8080
```

At the end, clean the environment:

```bash
./cleanup.sh
```
