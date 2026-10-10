# שיחת ChatGPT - המשך פרויקט Drupal

## משתמש
דפנה סיימה את החלק של הקמת Drupal ו-MySQL, יצירת משתמשים ותוכן, וגם יצרה גיבוי. מה נשאר לי לעשות לפי המטלה?

## עוזר
לפי חלוקת העבודה, החלק שנשאר לך הוא בעיקר החלק של בדיקה, שחזור, ניקוי ותיעוד:

- לבדוק שהשחזור מהגיבוי עובד
- לבדוק או להשלים את `backup.sh`
- להשלים את `restore.sh` אם צריך
- ליצור `cleanup.sh`
- להכין `README.md`
- לתעד שימוש ב-LLM בתיקיית `chats`
- לעשות כמה commits לאורך העבודה

---

## משתמש
אילו קבצים כבר קיימים ברפו ומה כדאי לבדוק קודם?

## עוזר
כדאי לבדוק קודם את הקבצים:

- `setup.sh`
- `backup.sh`
- `restore.sh`
- `my-drupal.backup.sql.gz`
- תיקיית `chats`

הבדיקה החשובה היא לראות אם אחרי `clone` אפשר להריץ:

```bash
chmod +x setup.sh backup.sh restore.sh
./setup.sh
./restore.sh
```

ואז לפתוח:

```text
http://localhost:8080
```

אם האתר עולה עם המשתמשים והתוכן, השחזור עובד.

---

## משתמש
מה `restore.sh` צריך לעשות?

## עוזר
הוא צריך:

1. לבדוק שקובץ הגיבוי קיים.
2. לבדוק שהקונטיינרים של MySQL ו-Drupal רצים.
3. להמתין ש-MySQL יהיה מוכן.
4. לפרוס את קובץ הגיבוי לתוך MySQL.
5. לוודא ש-Drupal יודע להתחבר לבסיס הנתונים.
6. להפעיל מחדש את Drupal.
7. להציג הודעה לפתוח את `localhost:8080`.

---

## משתמש
מה צריך להיות ב-`cleanup.sh`?

## עוזר
`cleanup.sh` צריך לנקות את סביבת העבודה של הפרויקט:

- לעצור ולמחוק את הקונטיינר של Drupal
- לעצור ולמחוק את הקונטיינר של MySQL
- למחוק את ה-volume של בסיס הנתונים
- למחוק את הרשת של Docker
- למחוק את התמונות `drupal:latest` ו-`mysql:latest` אם הן לא בשימוש

חשוב לא למחוק את קובץ הגיבוי מהרפו, כדי שאפשר יהיה לשחזר שוב בעתיד.

---

## משתמש
איך לבדוק שהסקריפטים תקינים בלי להריץ את כל Docker?

## עוזר
אפשר לבדוק תחביר Bash:

```bash
bash -n backup.sh
bash -n restore.sh
bash -n cleanup.sh
```

אם אין פלט ואין שגיאה, התחביר תקין.

בדיקה מלאה עדיין דורשת Docker:

```bash
./setup.sh
./restore.sh
```

ואז לפתוח את האתר בדפדפן.

---

## משתמש
מה צריך להיות ב-README?

## עוזר
ה-README צריך להסביר למשתמש פשוט:

- מי חברי הצוות
- מה נדרש בפרויקט
- מה עשיתם בפועל
- באילו טכנולוגיות השתמשתם
- איך עושים `clone`
- איך מריצים `setup.sh`
- איך משחזרים עם `restore.sh`
- איך פותחים את האתר
- איך יוצרים גיבוי חדש עם `backup.sh`
- איך מנקים את הסביבה עם `cleanup.sh`
- איפה נמצא תיעוד השימוש ב-LLM

---

## משתמש
איך כדאי לעשות commits?

## עוזר
לא כדאי לעשות commit אחד גדול בסוף. אפשר לחלק למשל כך:

```bash
git add backup.sh
git commit -m "Improve Drupal backup script"

git add restore.sh
git commit -m "Improve Drupal restore script"

git add cleanup.sh
git commit -m "Add Docker cleanup script"

git add README.md
git commit -m "Add project README"

git add chats/niv_codex_work.md
git commit -m "Document Niv LLM assistance"
```

בסוף:

```bash
git push
```

---

## משתמש
מה הבדיקה הסופית שאני צריכה לעשות לפני ההגשה?

## עוזר
להריץ:

```bash
chmod +x setup.sh backup.sh restore.sh cleanup.sh
./setup.sh
./restore.sh
```

אחר כך לפתוח:

```text
http://localhost:8080
```

ולוודא שהאתר עולה עם התוכן והמשתמשים מהגיבוי.

בסיום אפשר לבדוק את הניקוי:

```bash
./cleanup.sh
```

ולוודא שהקונטיינרים, הרשת וה-volumes של הפרויקט נמחקו.
