todo-git
======================
todo.txtでプログラミングの開発を管理している場合に向いています。　　

redmineなどでプロジェクトを管理して場合は向きません。

todo.txtでTODOを作成します。　　

そのTODOを元にgit flowでブランチを作成します。

featureとreleaseブランチを作成することができます。

使い方
------
### インストール###
インストールは、パスの通ったところにtodo-git.shファイルを置きます。  

chmod +x todo_git.sh  



### 設定 ###
todo.txtを読み込んでgitのブランチを作成するので、テキストエディタで
todo-git.shを開いて、todo.txtのパスを登録します。

バックアップファイルはDefaultではホームに作成します。

###How to do ###

+ todo.txtの最初の単語はブランチ名になります。
+ 途中で操作を中止したい場合、文字を入力してください。

>todo.sh add "new todo idea"   `---> new todo set`    
>todo-git.sh -s                         `---> "git flow feature start"` 

>...  (show some massage)

>1.new: todo idea`                     ----> inital word should be branch name`

>Select Number >>> 1 `            ----> new feature branch (feature/new) is made`

+ release branchを切るとき

>todo-git.sh -r

>... (show some massage and tag list)

+ release branchを終わるとき

>todo-git.sh -o

>... (show list)

>---> select number:

<参考>　　
http://momiji-mac.com/wp/2012/08/08/todo-gitの流れを書いてみました/


パラメータの解説
----------------

    ./todo_git.sh  -opt


+   `s` :  
    git flow feature start ...

+   `f` :  
    git flow feature finish ...

+   `e` :  
    edit todo.txt directly

+   `l` :  
    show todo list  
(リストに空行がある場合、自動的に削除します)　　

+   `r` :  
    git flow release start ... 
    select "q" --> cancel

+   `o` :  
    git flow release finish ...

+   `d` :  
    delete item of todo list ...

+   `x` :  
    exchange items from todo list ...


---
=== 追加項目 ===

+  `b` : sub-Feature branch start
  
+  `m`: sub-Feature branch marge and delete
  
+  `u`: sub-Feature branch just delete (= un-marge)

---
+  追加項目の説明：sub-Featureという概念を導入した。
		
	featureブランチ（test）で作業していて、新しい試したいアイデアを思いついたとする。

	<< 通常 >>

	(git)-[feature/test] > git checkout -b newTest

	(git)-[newTest] >

	<作業する…>
	
	<feature branch にマージし、戻りたい場合>

	(git)-[newTest] > git checkout feature/test
	
	(git)-[feature/test] > git marge newTest
	
	(git)-[feature/test] > git branch -d newTest
	
	<< sub-Featureを使う場合 >>
	
	(git)-[feature/test] > todo_git.sh -b newTest
	
	(git)-[newTest] >

	<作業する…>
	<feature branch に戻りたい場合>

	(git)-[newTest] > todo_git.sh -m
	
	merge and delete branch
	
	1 develop
	
	2 feature/subTest
	
	3 master
	
	4 * newTest
	
	Select feature branch --> 2   <--戻りたいfeatureを選択する
	
	... massage ...
	
	 
	つまり、margeと要らなくなったブランチを削除します。


ライセンス
----------
Copyright 2012 momiji-mac.com. All rights reserved.

Licensed under the [BSD License][BSD]  
Distributed under the [MIT License][mit].  

ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。

ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、momiji-mac.comの名前またはコントリビューターの名前を使用してはならない。
本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。