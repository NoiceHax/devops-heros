Git homework. Screenshots are in the screenshots folder.

01-commit-a-vs-m.png shows git commit -a -m vs git commit -m. -a does not pick up a new untracked file. After git add, editing that tracked file and using -a commits without another git add.

02-cherry-pick.png shows a feature branch with commits A B C, then cherry-pick of only B onto main. feature-b.txt is on main. A and C are not.
