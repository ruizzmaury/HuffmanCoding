with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO;         use Ada.Text_IO;
with d_conjunto;
with d_priority_queue;
with darbolbinario;
with dcola;

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


   package dcolaPareja is new dcola(parbol);
   use dcolaPareja;
   type pcola is access cola ;

   mainSet    :    conjunto;
   File       :    File_Type;
   File_Salida:    File_Type;
   File_Name  :    constant String := "entrada.txt";
   caracter   :    Character;
   pr_queue   : priority_queue;
   mainTree   : parbol;


   -- procedimiento que busca el caracter en el conjunto
   -- en el caso de que no exista pondríamos su frecuencia a 1
   -- si ya existe simplemente incrementamos su frecuencia
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


   -- procedimiento que se encarga de guardar en fichero de texto "entrada_freq.txt"
   -- las parejas clave-valor que se encuentran en el conjunto
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



   -- recorre el cojunto usando iterador, se crea mediante procedimiento graft
   -- arbol para cada pareja clave-valor y se inserta en cola prioridad
   -- usando procedimiento put
   procedure recorrerFreq(set: in out conjunto; q: in out priority_queue) is
      it: iterador;
      tree: parbol; -- elemento que se añadirá en cola prioridad
      emptyTree: parbol;
      pareja: nodo; -- Pareja clave-valor
      clave: Character;   -- variable que contendrá caracter
      valorFreq: Integer; -- variable que contendrá frecuencia caracter
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


   -- procedimiento que extrae de la cola prioridad cada una de
   -- las parejas clave-valor y las printea por consola
   procedure extraerArbolesCola(q: in out priority_queue) is
      currentTree : parbol; -- el nodo arbol
      currentPair: nodo;
   begin

      while not is_empty(q) loop -- mientras la cola no esté vacía
         currentTree := get_least(q);
         raiz(currentTree.all, currentPair);
         Put(currentPair.caracter);
         Put(": ");
         Put(currentPair.frequencia);
         delete_least(q);
         New_Line;
      end loop;


   end extraerArbolesCola;


   -- procedimiento de creación del Árbol Huffman extrayendo
   -- los elementos de la cola de prioridad
   function creacionArbolHuffman(q: in out priority_queue) return parbol is
      t1: parbol;
      t2: parbol;

      t1_pair: nodo;
      t2_pair: nodo;

      arbolUnion: parbol;
      arbolUnion_pair: nodo;

   begin
      -- comprobamos si la cola prioridad tiene dos o más elementos

      while not is_empty(q) loop
         -- extraemos elemento con más prioridad

         t1 := get_least(q);
         raiz(t1.all, t1_pair);
         delete_least(q); -- eliminamos elemento extraido


         -- si sigue sin estar vacía
         if not is_empty(q) then
            -- Contenia dos elementos (o mas )

            -- extraemos segundo elemento que es ahora el elemento con + prioridad

            t2 := get_least(q);
            delete_least(q);

            raiz(t2.all, t2_pair);

            -- inicializamos nuevo arbolUnion con la suma
            -- de los extraídos previamente
            arbolUnion:= new arbol;

            -- creamos el elem clave-valor del nuevo arbol  ----------------
            arbolUnion_pair.caracter := '-'; -- caracter vacío

            -- frecuencia del elem de la raiz del nuevo arbol será la suma
            -- de las frecuencias de los dos nodos extraídos
            arbolUnion_pair.frequencia := t1_pair.frequencia + t2_pair.frequencia;


            graft(arbolUnion.all, t1.all, t2.all, arbolUnion_pair);
            ----------------------------------------------------------------

            put(q, arbolUnion); -- Insertar el nuevo árbol en el heap.


         end if;


      end loop;

      return t1;
   end creacionArbolHuffman;


   -- procedimiento que se encarga de realizar el recorrido
   -- en amplitud del árbol huffman creado con anterioridad
   procedure recorridoAmplitud(mainTree : in out parbol) is
      raizT_aux: parbol;
      raizT_izq: parbol;
      raizT_der: parbol;
      pareja: nodo;
      nodosPendientes: cola;
   begin
      cvacia(nodosPendientes);

      if not esta_vacio(mainTree.all) then
         -- extraemos raiz del árbol

         poner(nodosPendientes, mainTree);
         raizT_aux := new arbol;

         while not esta_vacia(nodosPendientes) loop
            raizT_aux := coger_primero(nodosPendientes);
            raiz(raizT_aux.all, pareja);
            raizT_izq := new arbol;
            izq(raizT_aux.all, raizT_izq.all);
            Put(pareja.caracter);
            Put(": ");
            Put(pareja.frequencia);
            New_Line;

            if not esta_vacio(raizT_izq.all) then
               poner(nodosPendientes, raizT_izq);
               raizT_der := new arbol;
               der(raizT_aux.all, raizT_der.all);
               poner(nodosPendientes, raizT_der);

            end if;
            borrar_primero(nodosPendientes);
         end loop;

      end if;

   end recorridoAmplitud;


begin
   --  Insert code here.
   Open(File, In_File, File_Name);
   cvacio(mainSet); -- inicializamos conjunto
   empty(pr_queue); -- inicializamos cola prioridad
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

   -- extraerArbolesCola(pr_queue);

   -- construímos el árbol de Huffman
   mainTree := creacionArbolHuffman(pr_queue);

   recorridoAmplitud(mainTree);


end Main;


