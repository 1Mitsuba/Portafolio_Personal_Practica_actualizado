import type { Profile, Project } from './types'

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(path, {
    ...init,
    headers: { 'Content-Type': 'application/json', ...init?.headers },
  })
  if (!response.ok) {
    const body = await response.json().catch(() => ({}))
    throw new Error(body.detail ?? 'No se pudo completar la solicitud.')
  }
  return response.json() as Promise<T>
}

export const getProfile = () => request<Profile>('/api/profile')
export const getProjects = () => request<Project[]>('/api/projects')
export const sendContact = (payload: { name: string; email: string; message: string }) =>
  request<{ id: number; message: string }>('/api/contact', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
