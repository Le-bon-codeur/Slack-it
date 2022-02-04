# SLACK'IT

> **Slack'it** est un programme *perl* permettant d'envoyer des messages sur des *channels slack*.  
Deux types de messages peuvent être envoyés, le message par défaut et le message plus détaillé.  
Quelques prérequis sont necessaires. Suivez les étapes de la doc et envoyez simplement votre premier message.

## Prérequis

### Perl

*avec le gestionnaire de package apt*

```bash
$ sudo apt install perl
$ apt list --installed | grep -i perl
```

*si vous n'avez pas apt*

<https://www.perl.org/get.html | Perl download>

### Slack-App

> Créer une app Slack est relativement simple.  
Certains utilitaires permettent de communiquer via different protocoles,  
ici nous utiliserons les webhook, le but étant de faire des requetes  
HTTP POST avec l'url des channels des destinataires.

1. Créer un compte Slack
2. Se connecter et créer un workspace (ex: myWorkspace)
3. Se rendre sur SlackApi
4. Créer une app:
- Cliquez sur *Create an app*
- Sélectionnez *from scratch*
- ajoutez la dans *myWorkspace*
5. Permettre a l'app de communiquer:
- Allez dans *Incomming Webhook*
- Autorisé et cochant le bouton
- Cliquez sur *Add new Webhook* et selectionnez un channel

Vous savez maintenant comment récupérer l'URL d'un channel pour lui envoyer un message.

### La liste des destinataires

> Pour envoyer des messages, il vous faut des URLs (*récupérés au point précédent*).


Une fois les URLs associés a des noms de destinataire, il faut sauvegarder le couple (_nom-destinataire, url-destinataire_)  
Ouvrez le fichier `./Conf/url_list.txt`. Vous allez y rentrez le couple sous la forme: **_'nom' espace 'url'_**.  

La fonction get_slack_url() retrouve l'*url* d'un destinataire grace a son *nom* en cherchant dans ce fichier.txt,  
faites donc bien attention au format pour ne pas casser la fonction.

## Example d'utilisation

> A la fin du programme `./main.pl`, il y a une function appelé `sub main{ }`, c'est ici que vous appelerez vos fonctions.

### Envoyer un message simple

Il faut 3 arguments : *l'expediteur* du message, *le destinataire* et *le contenu*

```perl
sub main{
	send_slack_message('my_name','luc-dupont','lorem ipsum dorina voreli');
	return 1
}
```

On voit donc que `send_slack_message()` prend trois arguments en entré:
- nom de l'expediteur: 'my_name'
- nom du destinataire: 'luc-dupont'
   - important de bien l'écrir, il vas servir à retrouver l'url !
- le contenu du message: 'lorem ipsum dorina voreli'

Vous pouvez maintenant executer le script.

```bash
$ perl main.pl
```

### Envoyer un message detaillé

```perl
sub main{
	send_slack_message('my_name','luc-dupont','le colis a été endomagé, signalé par DPD-Paris-19', 'Feb 5 10:00:56', 'la commande 66f4dr7');
	return 1
}
```

Cette fonction envoi un message plus detaillé signalant un *problème* sur *un objet ou autre* en précisant *la date*

## Upgrade

- Lire des logs sur une machine et envoyer des message d'erreur
- Support client autonome
- Automatisation de rappel ou autre
- ...

---

*Author | Pierre-Louis Létoquart*
