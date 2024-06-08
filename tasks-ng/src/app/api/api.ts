export interface MyIP {
    ip?: string
}

export interface Task {
    id?: number
    title?: string
    description?: string
    done?: boolean
    userId?: number
}

export interface User {
    id?: number
    firstName?: string
    lastName?: string
    email?: string
    tasks?: Task[]
}