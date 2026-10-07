# SenActuPlus — site + espace admin (Vercel + Supabase)

Le site est statique (rien à compiler). Vercel l'héberge, Supabase gère le **login admin** et les **articles**.

## 1. Supabase (gratuit)
1. Créez un projet sur supabase.com.
2. **SQL Editor** → New query → collez tout `supabase.sql` → Run.
3. **Authentication → Users → Add user** : votre e-mail + un mot de passe solide (cochez « Auto Confirm »).
4. **Authentication → Sign In / Providers → Email** : désactivez « Allow new users to sign up ».
5. Dans le SQL Editor, exécutez (avec VOTRE e-mail) :
   `insert into public.admins (user_id) select id from auth.users where email = 'VOTRE_EMAIL@exemple.com';`
6. **Project Settings → API** : copiez *Project URL* et la clé *anon public*.

## 2. config.js
Collez l'URL et la clé anon dans `config.js`. (La clé anon est publique par conception ; ne mettez JAMAIS la clé `service_role` dans ce projet.)

## 3. Vercel
Glissez-déposez le dossier (ou poussez sur Git → Import Project). Aucune variable d'environnement n'est nécessaire.
- Site public : `https://votre-site.vercel.app/`
- Admin : `https://votre-site.vercel.app/admin`

## Sécurité
Le login est vérifié par Supabase ; l'écriture en base n'est autorisée qu'aux comptes listés dans la table `admins` (règles RLS). Même si quelqu'un lit `admin.html`, il ne peut ni publier ni supprimer sans être connecté en admin.

## Sans configuration
Tant que `config.js` est vide, le site public affiche les articles de démonstration et `/admin` indique qu'il faut configurer Supabase.
