
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO;         use Ada.Text_IO;
with d_conjunto;
with d_priority_queue;
with darbolbinario;
with dcola;

procedure Main is

   package dConjuntoLetras is new d_conjunto(Character, Integer);
   use dConjuntoLetras;

   -- nodo que constará de un caracter con su
   -- correspondiente frecuencia de aparición
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

   -- declaraciones
   mainSet    :    conjunto;
   File       :    File_Type;
   File_Salida:    File_Type;
   File_Name  :    constant String := "entrada.txt";
   caracter   :    Character;
   pr_queue   : priority_queue;
   mainTree   : parbol;

   -- código que constará de un array de 1s o 0s para cada carácter
   type codi is array (1..15) of Character;
   type tcodi is record
      c: codi;
      l: Natural;
   end record;

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
      Create(File_Salida, Out_File, File_Name);
      primero(set, it); -- nos posicionamos en primer elemento valido
      while es_valido(it) loop -- mientras haya elementos validos
         obtener(set, it, currentChar, charFreq); -- obtenemos valores elemento

         -- guardamos elemento en fichero

         Put(File_Salida, currentChar);

         Put(File_Salida, ':');

         Put(File_Salida, charFreq);

         Put_Line(File_Salida,"");

         siguiente(set, it); -- nos movemos al siguiente
      end loop;
      Close(File_Salida);
   end guardaCaracteres;



   -- recorre el conjunto usando iterador, se crea mediante procedimiento graft
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
         currentTree := get_least(q); -- extraemos pareja clave-valor de cola
         raiz(currentTree.all, currentPair);
         Put(currentPair.caracter);
         Put(": ");
         Put(currentPair.frequencia);
         delete_least(q); -- eliminamos pareja extraida para pasar a la siguiente
         New_Line;
      end loop;


   end extraerArbolesCola;


   -- funcion de creación del Árbol Huffman extrayendo
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



   -- procedimiento que realiza el recorrido en amplitud del árbol
   -- Huffman generado anteriormente. Se usará una cola de nodos
   -- pendientes a procesar "nodosPendientes" y un parbol auxiliar "raizT_aux"
   -- para tratar con cada uno de los nodos
   procedure recorridoAmplitud(mainTree : in out parbol) is
      raizT_aux: parbol;
      raizT_izq: parbol;
      raizT_der: parbol;
      pareja: nodo;
      nodosPendientes: cola;
   begin
      cvacia(nodosPendientes);

      if not esta_vacio(mainTree.all) then -- si el árbol no está vacio

         raizT_aux := new arbol;

         -- se extrae raiz del árbol
         poner(nodosPendientes, mainTree);

         while not esta_vacia(nodosPendientes) loop
            raizT_aux := coger_primero(nodosPendientes); -- cogemos 1r nodo cola
            raiz(raizT_aux.all, pareja);

            raizT_izq := new arbol;
            izq(raizT_aux.all, raizT_izq.all); -- hijo izquierdo de arbol auxiliar

            -- print pareja clave-valor
            Put(pareja.caracter);
            Put(": ");
            Put(pareja.frequencia);
            New_Line;

            if not esta_vacio(raizT_izq.all) then -- si hijo izquierdo no vacío
               poner(nodosPendientes, raizT_izq); -- introducimos hizquierdo en cola

               raizT_der := new arbol;
               der(raizT_aux.all, raizT_der.all); -- hijo derecho de arbol auxiliar

               poner(nodosPendientes, raizT_der); -- introducimos hderecho en cola

            end if;
            borrar_primero(nodosPendientes); -- eliminamos nodo de cola pendientes procesar
         end loop;

      end if;

   end recorridoAmplitud;


   procedure genera_codi(x: in arbol; c: in Character; trobat: in out boolean; idx: in Integer;
                         codi: in out tcodi) is
      -- codi se encuentra formado por :
      -- c: array de caracteres (0 , 1)
      -- l: natural que indica la longitud del codigo

      l, r: arbol;
      pareja : nodo;


   begin
      -- visitar nodo consiste en:
      -- comprobar si la raiz del arbol contiene el caracter
      if not trobat then
         -- Si no se ha encontrado el caracter :
         -- Bajar hacia el hijo izquierdo y anadir un '0'

         raiz(x,pareja);

         if pareja.caracter/= c then

            izq (x , l ) ;
            if not esta_vacio ( l ) then
               codi.c ( idx ) := '0';
               codi.l := idx ;
               genera_codi (l , c , trobat , idx + 1 , codi ) ;
            end if;
            -- Si no se ha encontrado el caracter :
            -- Bajar hacia el hijo derecho y anadir un '1'
            if not trobat then
               der(x, r);
               if not esta_vacio ( r ) then
                  codi.c ( idx ) := '1';
                  codi.l := idx ;
                  genera_codi (r , c , trobat , idx + 1 , codi ) ;
               end if;
            end if;
         else
            trobat:= true;

         end if;
      end if;

   end genera_codi;

   procedure generar_codificacion (set: in conjunto; tree: in out parbol) is
      it: iterador;
      pareja : nodo;
      codi: tcodi;
      c: Character;
      trobat : boolean;
      File_Name  :    constant String := "entrada_codi.txt";
   begin
      -- se crea el fichero de salida donde irán los caracteres con su codigo
      -- correspondiente
      Create(File_Salida, Out_File, File_Name);

      -- situamos el iterador del conjunto en primer elemento válido
      primero(set, it);
      trobat:= false;

      while es_valido(it) loop -- iteramos mientras iterador sea valido

         obtener(set, it, pareja.caracter, pareja.frequencia); -- leemos caracter del conjunto
         c:= pareja.caracter;

         genera_codi(tree.all, c, trobat, 1, codi); -- generamos código para carácter

         Put(File_Salida, c); -- guardamos caracter en fichero

         Put(File_Salida, ':');

         for i in 1..codi.l loop -- guardamos código de caracter en fichero
            Put(File_Salida, codi.c(i));
         end loop;

         siguiente(set, it); -- nos movemos al siguiente caracter del conjunto
         Put_Line(File_Salida,""); -- salto de linea
         trobat := false; -- volvemos a poner trobat a false


      end loop;
      Close(File_Salida); -- cerramos fichero
   end generar_codificacion;


begin
   -- abrimos fichero "entrada.txt" con texto
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

   -- recorremos el árbol
   recorridoAmplitud(mainTree);

   -- generamos codificación final
   generar_codificacion(mainSet, mainTree);


end Main;


