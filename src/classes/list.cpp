#include "list.hpp"

// Construtor
template <typename T>
List<T>::List(int initial_capacity) : _size(0), capacity(initial_capacity) {
    array = new T * [capacity](); // Inicializa com nullptr
}

// Destrutor
template <typename T>
List<T>::~List() {
    delete[] array;  // Libera apenas o array de ponteiros (n�o os elementos)
}

// M�todo para expandir capacidade
template <typename T>
void List<T>::expandCapacity() {
    capacity *= 2;
    T** temp = new T * [capacity]();
    for (long i = 0; i < _size; ++i) {
        temp[i] = array[i];  // Copia elementos antigos
    }
    delete[] array;  // Libera mem�ria antiga
    array = temp;
}

// M�todo para adicionar elemento
template <typename T>
void List<T>::add(T* element) {
    if (_size >= capacity) {
        expandCapacity();
    }
    array[_size++] = element;
}

// Define um elemento em um �ndice espec�fico
template <typename T>
void List<T>::set(long index, T* element) {
    if (index >= 0 && index < _size) {
        array[index] = element;
    }
}

// Retorna o tamanho da lista
template <typename T>
long List<T>::size() const {
    return _size;
}

// Retorna um elemento de um �ndice
template <typename T>
T* List<T>::get(long index) {
    if (index >= 0 && index < _size) {
        return array[index];
    }
    return nullptr;
}

// Remove um elemento (n�o deleta o ponteiro)
template <typename T>
void List<T>::remove(long index) {
    if (index >= 0 && index < _size) {
        delete array[index];  // Deleta o objeto armazenado
        for (long i = index; i < _size - 1; i++) {
            array[i] = array[i + 1];
        }
        _size--;
    }
}

// Deleta apenas o array de ponteiros (n�o os elementos)
template <typename T>
void List<T>::deleteList() {
    delete[] array;
    array = nullptr;
    _size = 0;
    capacity = 0;
}

// Deleta cada elemento e o array de ponteiros
template <typename T>
void List<T>::deepDeleteList() {
    for (long i = 0; i < _size; ++i) {
        delete array[i];  // Deleta cada elemento armazenado
    }
    delete[] array;  // Deleta o array de ponteiros
    array = nullptr;
    _size = 0;
    capacity = 0;
}

// Explicita��o dos templates usados
template class List<Point>;
template class List<float>;
template class List<int>;