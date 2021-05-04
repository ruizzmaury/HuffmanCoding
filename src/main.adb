with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO;         use Ada.Text_IO;
with d_conjunto;
with d_priority_queue;
with darbolbinario;

procedure Main is

   package dConjuntoLetras is new d_conjunto(Character, Integer);
   use dConjuntoLetras;

   type nodo is record
      caracter : Character ;
      frequencia : Integer ;
   end record ;

   package darbre is new darbolbinario ( elem  => nodo ) ;
   use darbre ;
   type parbol is access arbol ;

   function menor(x1,x2 : in parbol) return boolean is
      node1 : nodo;
      node2 : nodo;
   begin
      raiz(x1.all, node1);
      raiz(x2.all, node2);
      return node1.frequencia < node2.frequencia;
   end menor;

   function major(x1,x2 : in parbol) return boolean is
      node1 : nodo;
      node2 : nodo;
   begin
      raiz(x1.all, node1);
      raiz(x2.all, node2);
      return node1.frequencia > node2.frequencia;
   end major;

   package d_priority_queue_arbol is new d_priority_queue (size => 20 , item => parbol , "<" => menor, ">" => major);
   use d_priority_queue_arbol;


   mainSet    :    conjunto;
   File       :    File_Type;
   File_Salida:    File_Type;
   File_Name  :    constant String := "entrada.txt";
   caracter   :    Character;
   pr_queue: priority_queue;




   procedure buscaCaracter(c: in out Character; set: in out conjunto)  is
      it:    iterador;
      currentChar: Character;  -- key
      charFreq: Integer;  -- item

   begin
      primero(set, it);   -- nos posicionamos en primer elemento valido

      while es_valido(it) loop   -- mientras haya elementos validos
         obtener(set, it, currentChar, charFreq);  -- obtenemos valores elemento
         if currentChar = c then  -- si el elemento actual es el que estamos buscando:
            -- ya existe -> aumentamos su frecuencia
            actualiza(set, currentChar, charFreq+1);
            return;
         end if;
         -- charFreq:=0;
         siguiente(set, it); -- nos movemos al siguiente elemento valido
      end loop;
      poner(set, c, 1);   -- si no lo ha encontrado, introducimos elemento y frecuencia 1

   end buscaCaracter;


   procedure guardaCaracteres(set: in out conjunto) is
      it:    iterador;
      currentChar: Character; -- key
      charFreq: Integer;   -- item
      File_Name  :    constant String := "entrada_freq.txt";
   begin
      Open(File_Salida, Out_File, File_Name);
      primero(set, it); -- nos posicionamos en primer elemento valido
      while es_valido(it) loop -- mientras haya elementos validos
         obtener(set, it, currentChar, charFreq); -- obtenemos valores elemento

         -- guardamos elemento en fichero
         -- Put(currentChar);
         Put(File_Salida, currentChar);

         -- Put(':');
         Put(File_Salida, ':');

         -- Put(charFreq);
         Put(File_Salida, charFreq);

         -- Put_Line("");
         Put_Line(File_Salida,"");

         siguiente(set, it); -- nos movemos al siguiente
      end loop;
      Close(File_Salida);
   end guardaCaracteres;

   --recorre el conjunto mediante un iterador , creamos un arbol para cada pareja
   --de llave-valor mediante la funcion graft y lo insertamos en la cola de prioridad
   --con put(cola,elemento)
   procedure recorrerFreq(set: in out conjunto; q: in out priority_queue) is
      it: iterador;
      tree: parbol;
      emptyTree: parbol;
      pareja: nodo; -- Pareja clave-valor
      clave: Character;
      valorFreq: Integer;
   begin
      primero(set, it);

      while es_valido(it) loop
         -- creamos arbol binario de 1 nodo
         obtener(set, it, clave, valorFreq);
         tree := new arbol;
         emptyTree := new arbol;
         avacio(tree.all);
         avacio(emptyTree.all);
         pareja.caracter := clave;
         pareja.frequencia := valorFreq;
         --(clave);
         -- Put(valorFreq);
         graft(tree.all, emptyTree.all, emptyTree.all, pareja);
         put(q, tree);
         siguiente(set, it);
      end loop;
   end recorrerFreq;


   procedure extraerArbolesCola(q: in out priority_queue) is
      currentTree : parbol; -- el nodo arbol
      currentPair: nodo;
   begin

      while not is_empty(q) loop
         currentTree := get_least(q);
         raiz(currentTree.all, x => currentPair);
         Put(currentPair.caracter);
         Put(": ");
         Put(currentPair.frequencia);
         delete_least(q);
         New_Line;
      end loop;


   end extraerArbolesCola;

begin
   --  Insert code here.
   Open(File, In_File, File_Name);
   cvacio(mainSet); -- inicializamos conjunto
   empty(pr_queue);
   -- introducimos todos los caracteres del fichero en el conjunto
   while not End_Of_File (File) loop -- mientras no final de fichero
      Get_Immediate(File, caracter); -- leemos caracter

      buscaCaracter(caracter, mainSet);  -- buscamos caracter leído
      -- y actualizamos frecuencia
   end loop;
   Close(File);

   guardaCaracteres(mainSet);   -- guardamos en fichero entrada_freq
   -- cada uno de los caracteres con su frecuencia

   recorrerFreq(mainSet, pr_queue);

   extraerArbolesCola(pr_queue);

end Main;


